<#
    Prints the report in the console (-Console). The window is in Ui.ps1.
#>

$script:MaxShown = 20
$script:SeverityConsoleColors = @{ 3 = 'Red'; 2 = 'Yellow'; 1 = 'Gray' }

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host (' ' + ('-' * $Title.Length)) -ForegroundColor DarkCyan
}

function Write-Wrapped {
    # Word-wraps to the window width; later lines line up under the text, not the prefix
    param([string]$Text, [int]$Indent = 4, [string]$Prefix = '', [ConsoleColor]$Color = 'Gray')
    $width = 100
    try { if ($Host.UI.RawUI.WindowSize.Width -gt 40) { $width = $Host.UI.RawUI.WindowSize.Width - 2 } } catch { }
    $start = (' ' * $Indent) + $Prefix
    $hang  = ' ' * $start.Length
    $line  = $start
    $hasWords = $false
    foreach ($word in ($Text -split '\s+' | Where-Object { $_ })) {
        if ($hasWords -and ($line.Length + 1 + $word.Length) -gt $width) {
            Write-Host $line -ForegroundColor $Color
            $line = $hang + $word
        } elseif ($hasWords) {
            $line += " $word"
        } else {
            $line += $word
        }
        $hasWords = $true
    }
    if ($hasWords) { Write-Host $line -ForegroundColor $Color }
}

function Show-Report {
    param($Report, [ValidateSet('Severity', 'Recent')] [string]$SortBy = 'Severity', [switch]$All)

    Write-Host ''
    Write-Host " Crash Explainer $script:Version" -ForegroundColor Cyan
    Write-Host " Crashes from the last $($Report.Days) days. This tool only reads Windows' logs - it changes nothing." -ForegroundColor DarkGray

    $groups = @(Sort-CrashGroups $Report.Groups $SortBy)
    if (-not $groups) {
        Write-Section 'No crashes found'
        Write-Wrapped "Windows recorded no crashes, blue screens, freezes or sudden shutdowns in the last $($Report.Days) days. If something did crash, look further back, for example: CrashExplainer.ps1 -Days 30"
        return
    }
    Write-Wrapped $Report.Summary -Indent 1 -Color White

    if ($Report.BigPicture) {
        Write-Section 'The big picture'
        foreach ($note in $Report.BigPicture) { Write-Wrapped $note -Indent 2 -Prefix '* ' -Color White }
    }

    Write-Section $(if ($SortBy -eq 'Recent') { 'Crashes, most recent first' } else { 'Crashes, most serious first' })
    $shown = if ($All) { $groups } else { @($groups | Select-Object -First $script:MaxShown) }
    $number = 1
    foreach ($group in $shown) {
        $x = $group.Explanation
        Write-Host ''
        Write-Host ('  {0,2}. ' -f $number) -NoNewline
        Write-Host $x.Title -ForegroundColor $script:SeverityConsoleColors[$x.Severity] -NoNewline
        Write-Host ('  ({0}, {1})' -f $x.SeverityName.ToLower(), (Format-Occurrence $group)) -ForegroundColor DarkGray

        foreach ($paragraph in $x.Explain) { Write-Wrapped $paragraph -Indent 6 }
        if ($x.Involved)   { Write-Wrapped $x.Involved -Indent 6 -Prefix 'Involved: ' -Color DarkGray }
        if ($group.Detail) { Write-Wrapped $group.Detail -Indent 6 -Color DarkGray }
        if ($x.Fixes) {
            Write-Host '      Try this, in order:' -ForegroundColor White
            $step = 1
            foreach ($fix in $x.Fixes) { Write-Wrapped $fix -Indent 8 -Prefix "$step. "; $step++ }
        }
        if ($x.Search) { Write-Wrapped "`"$($x.Search)`"" -Indent 6 -Prefix 'Search online for: ' -Color DarkGray }
        $number++
    }

    if ($shown.Count -lt $groups.Count) {
        Write-Host ''
        Write-Wrapped ('{0} more entries not shown. Run with -All to see everything.' -f ($groups.Count - $shown.Count)) -Indent 2 -Color DarkGray
    }
}
