<#
    The Crash Explainer window (WPF, built into Windows).
    The logs are read when the window opens, and again when the period
    changes or Refresh is clicked. Reading runs in the background
    (Read-Report.ps1) and reports progress through a queue that a timer
    reads, so the window never freezes. Changing the sort order only
    reorders what was already read.
    The page (ui\Page.xaml) is shown by the standalone window and by the
    Crash Explainer tab in Krimz's Toolkit (modules\Page.ps1).
#>

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$script:Ui      = @{}   # named controls from ui\Page.xaml
$script:UiState = @{ Report = $null; Days = 14; SortBy = 'Severity'; Started = $false; Reading = $false }

$script:Colors = @{ Text = '#F3F3F3'; Muted = '#A6A6A6'; Accent = '#4CA6FF' }
# Severity 3 = Serious, 2 = Medium, 1 = Minor
$script:SeverityColors      = @{ 3 = '#FF99A4'; 2 = '#FCE100'; 1 = '#C8C8C8' }
$script:SeverityBackgrounds = @{ 3 = '#46262B'; 2 = '#3D3415'; 1 = '#383838' }

# ------------------------------------------------------------------
#  Small helpers
# ------------------------------------------------------------------

function Get-NativeMethods {
    # The few Windows functions the window needs, built in memory.
    # Not Add-Type: in PowerShell 5.1 that runs the C# compiler, which writes
    # temporary files to disk - and this tool must not write anything.
    if ($script:Native) { return $script:Native }
    $assembly = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object Reflection.AssemblyName 'CrashExplainerNative'), 'Run')
    $type = $assembly.DefineDynamicModule('CrashExplainerNative').DefineType('Native', 'Public, Class')
    $functions = @(
        @{ Dll = 'user32.dll'; Name = 'SetProcessDpiAwarenessContext'; Returns = [bool]; Parameters = @([IntPtr]) }
        @{ Dll = 'user32.dll'; Name = 'SetProcessDPIAware';            Returns = [bool]; Parameters = @() }
        @{ Dll = 'dwmapi.dll'; Name = 'DwmSetWindowAttribute';         Returns = [int];  Parameters = @([IntPtr], [int], [int].MakeByRefType(), [int]) }
    )
    foreach ($f in $functions) {
        $method = $type.DefinePInvokeMethod($f.Name, $f.Dll, 'Public, Static, PinvokeImpl', 'Standard', $f.Returns,
                                            [Type[]]$f.Parameters, 'Winapi', 'Auto')
        $method.SetImplementationFlags('PreserveSig')
    }
    $script:Native = $type.CreateType()
    $script:Native
}

function Enable-DpiAwareness {
    # Sharp text on high-resolution screens (otherwise Windows stretches the window and it looks blurry).
    # This only affects this program while it runs.
    try {
        $native = Get-NativeMethods
        if (-not $native::SetProcessDpiAwarenessContext([IntPtr]::new(-4))) { [void]$native::SetProcessDPIAware() }
    } catch { }
}

function Invoke-UiSafely {
    # An error inside a button or list handler must never close the window
    param([scriptblock]$Action)
    try { & $Action }
    catch {
        [System.Windows.MessageBox]::Show("Something went wrong:`n$($_.Exception.Message)", 'Crash Explainer', 'OK', 'Warning') | Out-Null
    }
}

function New-Text {
    param([string]$Text, [string]$Color = $script:Colors.Text, [double]$Size = 14, [string]$Weight = 'Normal', [string]$Margin = '0')
    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $Text
    $t.Foreground = $Color
    $t.FontSize = $Size
    $t.FontWeight = $Weight
    $t.Margin = $Margin
    $t.TextWrapping = 'Wrap'
    $t
}

function New-SelectableText {
    # Looks like text but can be selected and copied (file paths)
    param([string]$Text, [string]$Color = $script:Colors.Muted, [double]$Size = 13, [string]$Margin = '0')
    $t = New-Object System.Windows.Controls.TextBox
    $t.Text = $Text
    $t.Foreground = $Color
    $t.FontSize = $Size
    $outer = [System.Windows.Thickness]$Margin
    $outer.Left -= 2   # a TextBox has 2px of inner padding; this lines it up with normal text
    $t.Margin = $outer
    $t.IsReadOnly = $true
    $t.TextWrapping = 'Wrap'
    $t.Background = 'Transparent'
    $t.BorderThickness = 0
    $t.Padding = 0
    $t.CaretBrush = 'Transparent'
    $t
}

function Open-Link {
    # Opens a web page in the browser. Through Windows Explorer, so the browser
    # never runs with admin rights (Krimz's Toolkit runs as admin).
    param([string]$Url)
    Start-Process -FilePath 'explorer.exe' -ArgumentList "`"$Url`""
}

function New-SeverityChip {
    param([int]$Severity, [string]$Name)
    $chip = New-Object System.Windows.Controls.Border
    $chip.Background = $script:SeverityBackgrounds[$Severity]
    $chip.CornerRadius = 4
    $chip.Padding = '7,1'
    $chip.VerticalAlignment = 'Center'
    $chip.Child = New-Text $Name.ToUpper() $script:SeverityColors[$Severity] 11 'SemiBold'
    $chip
}

function New-ChipRow {
    # Severity chip followed by the kind of crash: [SERIOUS] Blue screen
    param($Explanation, [string]$Margin = '0')
    $row = New-Object System.Windows.Controls.StackPanel
    $row.Orientation = 'Horizontal'
    $row.Margin = $Margin
    [void]$row.Children.Add((New-SeverityChip $Explanation.Severity $Explanation.SeverityName))
    $kind = New-Text $Explanation.Kind $script:Colors.Muted 12 -Margin '8,0,0,0'
    $kind.VerticalAlignment = 'Center'
    [void]$row.Children.Add($kind)
    $row
}

function Add-Section {
    param([string]$Title)
    [void]$script:Ui.DetailPanel.Children.Add((New-Text $Title $script:Colors.Muted 12 'SemiBold' '0,20,0,8'))
}

function Show-Status {
    # Replaces the list and details with a message (reading, nothing found)
    param([string]$Title, [string]$Text = '', [switch]$Progress)
    $script:Ui.StatusTitle.Text = $Title
    $script:Ui.StatusText.Text  = $Text
    $script:Ui.ReadProgress.Visibility = if ($Progress) { 'Visible' } else { 'Collapsed' }
    $script:Ui.StatusPanel.Visibility = 'Visible'
    $script:Ui.MainArea.Visibility    = 'Collapsed'
}

function Hide-Status {
    $script:Ui.StatusPanel.Visibility = 'Collapsed'
    $script:Ui.MainArea.Visibility    = 'Visible'
}

# ------------------------------------------------------------------
#  Crash list
# ------------------------------------------------------------------

function New-CrashListItem {
    param($Group)
    $x = $Group.Explanation
    $panel = New-Object System.Windows.Controls.StackPanel
    [void]$panel.Children.Add((New-ChipRow $x))
    [void]$panel.Children.Add((New-Text $x.Title -Weight 'SemiBold' -Margin '0,7,0,2'))
    [void]$panel.Children.Add((New-Text (Format-Occurrence $Group) $script:Colors.Muted 12))

    $item = New-Object System.Windows.Controls.ListBoxItem
    $item.Content = $panel
    $item.Tag = $Group
    $item
}

function Update-List {
    # Fills the list in the chosen order and keeps the selected crash selected
    $s    = $script:UiState
    $list = $script:Ui.CrashList
    $selected = if ($list.SelectedItem) { $list.SelectedItem.Tag }
    $list.Items.Clear()
    foreach ($group in @(Sort-CrashGroups $s.Report.Groups $s.SortBy)) {
        $item = New-CrashListItem $group
        [void]$list.Items.Add($item)
        if ([object]::ReferenceEquals($group, $selected)) { $item.IsSelected = $true }
    }
    if ($list.SelectedIndex -lt 0 -and $list.Items.Count) { $list.SelectedIndex = 0 }
    if ($list.SelectedItem) { $list.ScrollIntoView($list.SelectedItem) }
}

# ------------------------------------------------------------------
#  Details of the selected crash
# ------------------------------------------------------------------

function Show-Detail {
    param($Group)
    $panel = $script:Ui.DetailPanel
    $panel.Children.Clear()
    $script:Ui.DetailScroll.ScrollToTop()
    if (-not $Group) { return }
    $x = $Group.Explanation

    [void]$panel.Children.Add((New-ChipRow $x))
    [void]$panel.Children.Add((New-Text $x.Title -Size 20 -Weight 'SemiBold' -Margin '0,8,0,4'))
    $when = if ($Group.Count -gt 1) {
        'Happened {0} times - first {1}, last {2}' -f $Group.Count, (Format-When $Group.First), (Format-When $Group.Last)
    } else {
        'Happened {0}' -f (Format-When $Group.Last)
    }
    [void]$panel.Children.Add((New-Text $when $script:Colors.Muted 13))

    Add-Section 'WHAT HAPPENED'
    foreach ($paragraph in $x.Explain) {
        $t = New-Text $paragraph -Margin '0,0,0,8'
        $t.LineHeight = 21
        [void]$panel.Children.Add($t)
    }

    if ($x.Involved -or $Group.Detail) {
        Add-Section 'WHAT WAS INVOLVED'
        if ($x.Involved)   { [void]$panel.Children.Add((New-SelectableText $x.Involved $script:Colors.Text 13 '0,0,0,4')) }
        if ($Group.Detail) { [void]$panel.Children.Add((New-SelectableText $Group.Detail)) }
    }

    if ($x.Fixes) {
        Add-Section 'TRY THIS, IN ORDER'
        $step = 1
        foreach ($fix in $x.Fixes) {
            $row = New-Object System.Windows.Controls.Grid
            $row.Margin = '0,0,0,10'
            $row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = 'Auto' }))
            $row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
            $badge = New-Object System.Windows.Controls.Border
            $badge.Width = 22; $badge.Height = 22; $badge.CornerRadius = 11
            $badge.Background = '#1A3550'
            $badge.Margin = '0,0,12,0'
            $badge.VerticalAlignment = 'Top'
            $number = New-Text "$step" $script:Colors.Accent 12 'SemiBold'
            $number.HorizontalAlignment = 'Center'; $number.VerticalAlignment = 'Center'
            $badge.Child = $number
            $text = New-Text $fix
            $text.LineHeight = 21
            [System.Windows.Controls.Grid]::SetColumn($text, 1)
            [void]$row.Children.Add($badge); [void]$row.Children.Add($text)
            [void]$panel.Children.Add($row)
            $step++
        }
    }

    if ($x.Search) {
        Add-Section 'FIND MORE ONLINE'
        [void]$panel.Children.Add((New-SelectableText "`"$($x.Search)`"" -Margin '0,0,0,10'))
        $buttons = New-Object System.Windows.Controls.StackPanel
        $buttons.Orientation = 'Horizontal'
        $search = New-Object System.Windows.Controls.Button
        $search.Content = 'Search online'
        $search.Style = $script:Ui.Page.FindResource('AccentButton')
        $search.Tag = $x.Search
        $search.Add_Click({ Invoke-UiSafely { Open-Link ('https://www.google.com/search?q=' + [uri]::EscapeDataString($this.Tag)) } })
        $copy = New-Object System.Windows.Controls.Button
        $copy.Content = 'Copy'
        $copy.Margin = '8,0,0,0'
        $copy.Tag = $x.Search
        $copy.Add_Click({ Invoke-UiSafely { [System.Windows.Clipboard]::SetText($this.Tag); $this.Content = 'Copied' } })
        [void]$buttons.Children.Add($search); [void]$buttons.Children.Add($copy)
        [void]$panel.Children.Add($buttons)
    }
}

# ------------------------------------------------------------------
#  Reading the logs
# ------------------------------------------------------------------

function Set-ChoicesEnabled {
    # Period, sort and Refresh are off while reading
    param([bool]$Enabled)
    foreach ($name in 'Days7', 'Days14', 'Days30', 'Days90', 'SortSeverity', 'SortRecent', 'RefreshButton') {
        $script:Ui[$name].IsEnabled = $Enabled
    }
}

function Start-Reading {
    # Reads the logs in a background runspace (Read-Report.ps1), so the window never freezes
    $s = $script:UiState
    if ($s.Reading) { return }
    $s.Reading = $true
    Set-ChoicesEnabled $false
    Set-ReadingBusy $true
    $script:Ui.SummaryText.Text = ''
    $script:Ui.BigPictureCard.Visibility = 'Collapsed'
    $script:Ui.ReadProgress.Value = 0
    Show-Status 'Reading Windows crash logs...' ' ' -Progress

    $s.Queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[object]'
    $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $iss.ExecutionPolicy = 'Bypass'   # for this runspace only; nothing is changed on the PC
    $s.Runspace = [runspacefactory]::CreateRunspace($iss)
    $s.Runspace.Open()
    $s.PowerShell = [powershell]::Create()
    $s.PowerShell.Runspace = $s.Runspace
    [void]$s.PowerShell.AddCommand((Join-Path $s.Root 'modules\Read-Report.ps1')).
        AddParameter('Root', $s.Root).AddParameter('Days', $s.Days).AddParameter('Queue', $s.Queue)
    $s.Handle = $s.PowerShell.BeginInvoke()

    if (-not $s.Timer) {
        $s.Timer = New-Object System.Windows.Threading.DispatcherTimer
        $s.Timer.Interval = [TimeSpan]::FromMilliseconds(100)
        $s.Timer.Add_Tick({ Invoke-UiSafely { Receive-Reading } })
    }
    $s.Timer.Start()
}

function Receive-Reading {
    # Called by the timer: shows progress, and the result once reading is done
    $s = $script:UiState
    $message = $null
    while ($s.Reading -and $s.Queue.TryDequeue([ref]$message)) {
        switch ($message.Type) {
            'Progress' {
                $script:Ui.StatusText.Text = "$($message.Label)..."
                $script:Ui.ReadProgress.Value = $message.Percent
            }
            'Done'  { Stop-Reading; Show-ReportResult $message.Report }
            'Error' { Stop-Reading; Show-Status 'Could not read the crash logs' $message.Message }
        }
    }
    # Reading stopped without saying why (should not happen, but never hang)
    if ($s.Reading -and $s.Handle.IsCompleted -and $s.Queue.IsEmpty) {
        $errors = @($s.PowerShell.Streams.Error | ForEach-Object { $_.ToString() }) -join ' '
        Stop-Reading
        Show-Status 'Could not read the crash logs' $(if ($errors) { $errors } else { 'Reading stopped unexpectedly.' })
    }
}

function Stop-Reading {
    # Also used when the window is closed while reading
    $s = $script:UiState
    if ($s.Timer) { $s.Timer.Stop() }
    if ($s.PowerShell) {
        try { if (-not $s.Handle.IsCompleted) { $s.PowerShell.Stop() } } catch { }
        $s.PowerShell.Dispose()
        $s.Runspace.Dispose()
        $s.PowerShell = $null
        $s.Runspace   = $null
    }
    $s.Reading = $false
    Set-ChoicesEnabled $true
    Set-ReadingBusy $false
}

function Set-ReadingBusy {
    # Tells Krimz's Toolkit (if the page is shown there) that the logs are being read
    param([bool]$Busy)
    if ($script:UiState.OnBusy) { try { & $script:UiState.OnBusy $Busy } catch { } }
}

function Show-ReportResult {
    param($Report)
    $s = $script:UiState
    $s.Report = $Report
    $script:Ui.CrashList.Items.Clear()
    if (-not $s.Report.Groups) {
        Show-Status 'No crashes found' ("Windows recorded no crashes, blue screens, freezes or sudden shutdowns in the last $($s.Days) days." +
                                        $(if ($s.Days -lt 90) { ' If something did crash, try a longer period above.' }))
        return
    }

    $script:Ui.SummaryText.Text = '{0} in the last {1} days.' -f $s.Report.Summary, $s.Days
    $notes = $script:Ui.BigPicturePanel
    $notes.Children.Clear()
    foreach ($note in $s.Report.BigPicture) {
        $t = New-Text $note -Size 13 -Margin '0,2'
        $t.LineHeight = 20
        [void]$notes.Children.Add($t)
    }
    if ($s.Report.BigPicture) { $script:Ui.BigPictureCard.Visibility = 'Visible' }

    Hide-Status
    Update-List
}

# ------------------------------------------------------------------
#  Page and window
# ------------------------------------------------------------------

function Import-CrashTheme {
    # The shared look (Theme.xaml) becomes the application's resources, so the
    # page finds its styles. Krimz's Toolkit does this itself.
    param([string]$Root)
    [xml]$xaml = Get-Content (Join-Path $Root 'ui\Theme.xaml') -Raw -Encoding UTF8
    $theme = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
    $app = [System.Windows.Application]::Current
    if (-not $app) { $app = New-Object System.Windows.Application }
    $app.ShutdownMode = 'OnExplicitShutdown'
    $app.Resources = $theme
}

function New-CrashPage {
    <#
        Builds the page (ui\Page.xaml) and wires it up. Used by the standalone
        window below and by Krimz's Toolkit (modules\Page.ps1). Reading starts
        with Start-CrashPage. -OnBusy is called with $true / $false around reading.
    #>
    param([string]$Root, [string]$Version, [int]$Days = 14, [string]$SortBy = 'Severity', [scriptblock]$OnBusy)

    [xml]$xaml = Get-Content (Join-Path $Root 'ui\Page.xaml') -Raw -Encoding UTF8
    $page = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
    $script:Ui.Page = $page
    $xaml.SelectNodes('//*[@*[local-name()="Name"]]') | ForEach-Object {
        $name = $_.GetAttribute('Name', 'http://schemas.microsoft.com/winfx/2006/xaml')
        if ($name) { $script:Ui[$name] = $page.FindName($name) }
    }

    $s = $script:UiState
    $s.Root   = $Root
    $s.Days   = $Days
    $s.SortBy = $SortBy
    $s.OnBusy = $OnBusy
    $script:Ui.VersionText.Text = "v$Version"

    # Choices are set before the handlers are added, so setting them doesn't trigger a read
    $dayButton = $script:Ui["Days$Days"]
    if ($dayButton) { $dayButton.IsChecked = $true }
    $script:Ui["Sort$SortBy"].IsChecked = $true

    foreach ($days in 7, 14, 30, 90) {
        $script:Ui["Days$days"].Add_Checked({
            Invoke-UiSafely { $script:UiState.Days = [int]$this.Tag; Start-Reading }
        })
    }
    $script:Ui.SortSeverity.Add_Checked({ Invoke-UiSafely { $script:UiState.SortBy = 'Severity'; if ($script:UiState.Report) { Update-List } } })
    $script:Ui.SortRecent.Add_Checked({   Invoke-UiSafely { $script:UiState.SortBy = 'Recent';   if ($script:UiState.Report) { Update-List } } })
    $script:Ui.RefreshButton.Add_Click({ Invoke-UiSafely { Start-Reading } })
    $script:Ui.CrashList.Add_SelectionChanged({
        Invoke-UiSafely { Show-Detail $(if ($script:Ui.CrashList.SelectedItem) { $script:Ui.CrashList.SelectedItem.Tag }) }
    })
    $page
}

function Start-CrashPage {
    # The first read, once the page is on screen (window opened / tab selected)
    if ($script:UiState.Started) { return }
    $script:UiState.Started = $true
    Start-Reading
}

function Show-CrashWindow {
    # The standalone window. -NoShow builds it without opening it (used for automated screenshots)
    param([string]$Root, [string]$Version, [int]$Days = 14, [string]$SortBy = 'Severity', [switch]$NoShow)

    Enable-DpiAwareness
    Import-CrashTheme $Root
    [xml]$xaml = Get-Content (Join-Path $Root 'ui\MainWindow.xaml') -Raw -Encoding UTF8
    $window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
    $script:Ui.Window = $window
    $window.Content = New-CrashPage -Root $Root -Version $Version -Days $Days -SortBy $SortBy

    # Dark title bar to match the window (Windows 10 2004+ / Windows 11)
    $window.Add_SourceInitialized({
        try {
            $hwnd = (New-Object System.Windows.Interop.WindowInteropHelper $script:Ui.Window).Handle
            $on = 1
            $native = Get-NativeMethods
            [void]$native::DwmSetWindowAttribute($hwnd, 20, [ref]$on, 4)
        } catch { }
    })

    # Start reading once the window is on screen
    $window.Add_ContentRendered({ Invoke-UiSafely { Start-CrashPage } })
    $window.Add_Closed({ Stop-Reading })

    if ($NoShow) { return $window }
    [void]$window.ShowDialog()
}
