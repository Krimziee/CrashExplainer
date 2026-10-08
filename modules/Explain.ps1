<#
    Groups repeated crashes together and matches them against the rules
    in the rules folder to get a plain-words explanation and fixes.
    Everything here is shared by the window (Ui.ps1) and the console report (Report.ps1).
#>

$script:KindOrder = 'BlueScreen', 'SuddenShutdown', 'Hardware', 'GpuReset', 'AppCrash', 'AppHang'
$script:MaxFixes  = 5

$script:KindNames = @{
    BlueScreen     = 'blue screen', 'blue screens'
    SuddenShutdown = 'sudden shutdown', 'sudden shutdowns'
    Hardware       = 'hardware error', 'hardware errors'
    GpuReset       = 'graphics driver reset', 'graphics driver resets'
    AppCrash       = 'program crash', 'program crashes'
    AppHang        = 'program freeze', 'program freezes'
}

# Severity is a number so it sorts: 3 = Serious, 2 = Medium, 1 = Minor
$script:SeverityNames = @{ 3 = 'Serious'; 2 = 'Medium'; 1 = 'Minor' }

function Get-CrashReport {
    # Reads the logs and explains everything: what both the window and the console show
    param([int]$Days)
    $crashes = @(Get-CrashEvents -Since (Get-Date).Date.AddDays(-$Days))
    $groups  = @(Group-Crashes $crashes)
    foreach ($group in $groups) { $group.Explanation = Get-Explanation $group }
    [pscustomobject]@{
        Days       = $Days
        Groups     = $groups
        BigPicture = @(Get-BigPicture $groups)
        Summary    = Get-CrashSummary $groups
    }
}

function Sort-CrashGroups {
    param([object[]]$Groups, [ValidateSet('Severity', 'Recent')] [string]$By = 'Severity')
    if ($By -eq 'Recent') {
        $Groups | Sort-Object Last -Descending
    } else {
        $Groups | Sort-Object @{ Expression = { $_.Explanation.Severity }; Descending = $true },
                              @{ Expression = 'Count'; Descending = $true },
                              @{ Expression = 'Last';  Descending = $true }
    }
}

function Get-Severity {
    param($Group, [string[]]$Categories)
    switch ($Group.Kind) {
        'BlueScreen'     { 3 }
        'SuddenShutdown' { if ($Group.Code -eq 'PowerLoss') { 3 } else { 2 } }
        'Hardware'       { if ($Categories -contains 'Hardware') { 3 } else { 1 } }   # corrected errors are minor
        'GpuReset'       { 2 }
        'AppCrash'       { 2 }
        default          { 1 }
    }
}

# ------------------------------------------------------------------
#  Wording shared by the window and the console
# ------------------------------------------------------------------

function Format-Count {
    param([int]$Count, [string[]]$Names)
    '{0} {1}' -f $Count, $(if ($Count -eq 1) { $Names[0] } else { $Names[1] })
}

function Get-CrashSummary {
    param([object[]]$Groups)
    $totals = foreach ($kind in $script:KindOrder) {
        $count = ($Groups | Where-Object Kind -eq $kind | Measure-Object Count -Sum).Sum
        if ($count) { Format-Count $count $script:KindNames[$kind] }
    }
    if ($totals) { 'Found ' + ($totals -join ', ') } else { 'Nothing found' }
}

function Format-When {
    param([datetime]$Time)
    $today = (Get-Date).Date
    if ($Time.Date -eq $today)             { return 'today ' + $Time.ToString('HH:mm') }
    if ($Time.Date -eq $today.AddDays(-1)) { return 'yesterday ' + $Time.ToString('HH:mm') }
    $Time.ToString('d MMM yyyy, HH:mm', [Globalization.CultureInfo]::InvariantCulture)
}

function Format-Occurrence {
    param($Group)
    if ($Group.Count -gt 1) { '{0} times, last {1}' -f $Group.Count, (Format-When $Group.Last) }
    else { Format-When $Group.Last }
}

function Import-Rules {
    param([string]$Folder)
    $script:Rules = @{
        BugChecks  = Import-PowerShellDataFile (Join-Path $Folder 'BugChecks.psd1')
        Exceptions = Import-PowerShellDataFile (Join-Path $Folder 'Exceptions.psd1')
        Modules    = (Import-PowerShellDataFile (Join-Path $Folder 'Modules.psd1')).Modules
        General    = Import-PowerShellDataFile (Join-Path $Folder 'General.psd1')
    }
}

function Group-Crashes {
    # The same crash happening again (same kind, program, file and code) becomes one entry
    param([object[]]$Crashes)
    $Crashes | Group-Object { '{0}|{1}|{2}|{3}' -f $_.Kind, $_.App, $_.Module, $_.Code } | ForEach-Object {
        $items = @($_.Group | Sort-Object Time)
        $last  = $items[-1]
        [pscustomobject]@{
            Kind        = $last.Kind
            App         = $last.App
            Module      = $last.Module
            ModulePath  = $last.ModulePath
            AppPath     = $last.AppPath
            Code       = $last.Code
            Detail      = $last.Detail
            Count       = $items.Count
            First       = $items[0].Time
            Last        = $last.Time
            Explanation = $null
        }
    }
}

function Find-ModuleRule {
    param([string]$Name)
    if (-not $Name) { return }
    foreach ($rule in $script:Rules.Modules) {
        foreach ($pattern in $rule.Match) {
            if ($Name -like $pattern) { return $rule }
        }
    }
}

function Test-ReplacedWindowsFile {
    # Mods, ReShade and mod loaders work by putting their own copy of a Windows
    # file (dxgi.dll, dinput8.dll...) in the game folder
    param($Group)
    if (-not $Group.ModulePath -or $Group.Module -notin $script:Rules.General.ReplacedWindowsFile.Names) { return $false }
    -not (Test-InWindowsFolder $Group.ModulePath)
}

function Test-InWindowsFolder {
    param([string]$Path)
    $Path -and $Path -like "$env:SystemRoot\*"
}

function Get-Explanation {
    param($Group)
    $general    = $script:Rules.General
    $rule       = $null
    $moduleRule = $null
    $baseFixes  = $null   # replaces $rule.Fixes when set
    $search     = ''

    switch ($Group.Kind) {
        'BlueScreen' {
            $rule = $script:Rules.BugChecks[$Group.Code]
            if ($rule) {
                $title  = 'Blue screen: {0} ({1})' -f $rule.Name, $Group.Code
                $search = '{0} blue screen' -f $rule.Name
            } else {
                $rule   = $general.UnknownBlueScreen
                $title  = 'Blue screen ({0})' -f $Group.Code
                $search = 'blue screen {0}' -f $Group.Code
            }
        }
        'SuddenShutdown' {
            $rule  = $general[$Group.Code]
            $title = $rule.Title
        }
        'Hardware' {
            $rule = $general.Whea[$Group.Code]
            if (-not $rule) { $rule = $general.Whea.Other }
            $title = 'Hardware error: {0}' -f $rule.Title
        }
        'GpuReset' {
            $rule       = $general.GpuReset
            $title      = $rule.Title
            $moduleRule = Find-ModuleRule $Group.Module
        }
        'AppHang' {
            $rule  = $general.AppHang
            $title = '{0} froze' -f $Group.App
        }
        'AppCrash' {
            $rule  = $script:Rules.Exceptions[$Group.Code]
            $what  = if ($rule) { $rule.Name } else { "error 0x$($Group.Code)" }
            $title = '{0} crashed ({1})' -f $Group.App, $what
            $ownCode = $Group.Module -eq $Group.App
            $search = (@($Group.App, 'crash', $(if (-not $ownCode) { $Group.Module }), "0x$($Group.Code)") | Where-Object { $_ }) -join ' '
            if (-not $rule) { $rule = $general.UnknownException }

            # Which file the crash happened in usually says more than the error code
            if ($Group.Module -and $ownCode)         { $moduleRule = $general.AppOwnCode }
            elseif (Test-ReplacedWindowsFile $Group) { $moduleRule = $general.ReplacedWindowsFile }
            else                                     { $moduleRule = Find-ModuleRule $Group.Module }

            # A Windows program (Explorer, dwm...) crashing gets Windows fixes, not game fixes
            if (Test-InWindowsFolder $Group.AppPath) {
                $baseFixes = $general.WindowsProgram.Fixes
                if (-not $moduleRule -and $Group.ModulePath -and -not (Test-InWindowsFolder $Group.ModulePath)) {
                    $moduleRule = $general.AddOnInWindowsProgram
                }
            }
        }
    }

    $explain = New-Object System.Collections.Generic.List[string]
    $explain.Add($rule.Explain)

    $involved = $Group.Module
    if ($moduleRule) {
        $involved = '{0} - {1}' -f $Group.Module, $moduleRule.Component
        $explain.Add($moduleRule.Explain)
    }
    # Show where an unknown or third-party file lives; the folder often tells you what installed it
    if ($Group.ModulePath -and (-not $moduleRule -or $moduleRule -in $general.ReplacedWindowsFile, $general.AddOnInWindowsProgram)) {
        $involved = '{0} ({1})' -f $involved, $Group.ModulePath
    }

    # The file-specific fixes are more precise, so they come first
    if (-not $baseFixes) { $baseFixes = $rule.Fixes }
    $fixes = New-Object System.Collections.Generic.List[string]
    foreach ($fix in @($moduleRule.Fixes) + @($baseFixes)) {
        if ($fix -and -not $fixes.Contains($fix)) { $fixes.Add($fix) }
    }

    $categories = @($rule.Category, $moduleRule.Category | Where-Object { $_ })
    $kindName   = $script:KindNames[$Group.Kind][0]
    $severity   = [int](Get-Severity $Group $categories)
    [pscustomobject]@{
        Title        = $title
        Kind         = $kindName.Substring(0, 1).ToUpper() + $kindName.Substring(1)
        Severity     = $severity
        SeverityName = $script:SeverityNames[$severity]
        Explain      = $explain.ToArray()
        Involved     = $involved
        Fixes        = @($fixes | Select-Object -First $script:MaxFixes)
        Search       = $search
        Categories   = $categories
    }
}

function Get-BigPicture {
    # Patterns across all crashes. One cause behind many crashes is common,
    # and fixing it is worth more than going through crashes one by one.
    param([object[]]$Groups)
    $text  = $script:Rules.General.BigPicture
    $notes = New-Object System.Collections.Generic.List[string]
    $inCategory = { param($name) @($Groups | Where-Object { $_.Explanation.Categories -contains $name }) }

    if ((& $inCategory 'Hardware').Count) { $notes.Add($text.Hardware) }

    $blueCodes = @($Groups | Where-Object Kind -eq 'BlueScreen' | ForEach-Object Code | Select-Object -Unique)
    if ($blueCodes.Count -ge 2) { $notes.Add(($text.ManyBlueScreens -f $blueCodes.Count)) }

    $gpuEvents = (& $inCategory 'Gpu' | Measure-Object Count -Sum).Sum
    if ($gpuEvents -ge 3) { $notes.Add(($text.Gpu -f $gpuEvents)) }

    $overlays    = @(& $inCategory 'Overlay' | Where-Object Kind -eq 'AppCrash')
    $overlayApps = @($overlays | ForEach-Object App | Select-Object -Unique)
    if ($overlayApps.Count -ge 2) {
        $notes.Add(($text.Overlay -f ((@($overlays | ForEach-Object Module | Select-Object -Unique)) -join ', ')))
    }

    $Groups | Where-Object Kind -eq 'AppCrash' | Group-Object Code | ForEach-Object {
        $apps = @($_.Group | ForEach-Object App | Select-Object -Unique)
        if ($apps.Count -ge 3) { $notes.Add(($text.SameErrorManyApps -f $apps.Count, "0x$($_.Name)")) }
    }

    $powerLoss = (@($Groups | Where-Object { $_.Kind -eq 'SuddenShutdown' -and $_.Code -eq 'PowerLoss' }) | Measure-Object Count -Sum).Sum
    if ($powerLoss -ge 2) { $notes.Add(($text.Power -f $powerLoss)) }

    $notes.ToArray()
}
