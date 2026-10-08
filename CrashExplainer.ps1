#Requires -Version 5.1
<#
    Crash Explainer
    Explains recent crashes, blue screens, freezes and sudden shutdowns in
    plain words, and suggests what to try, easiest fixes first.

    THIS TOOL MAKES NO CHANGES TO THE PC. It only reads the crash records
    Windows already keeps in its event logs. Fixes are shown as text for
    the user to do themselves. Anyone changing this script must keep it that way.

    No admin rights are needed: the System and Application logs can be read
    by every user.

    Opens a window by default.
    -Console                    Text report in the console instead of the window
    -Days 30                    How far back to look (default 14, up to 90)
    -SortBy Severity | Recent   Most serious first (default) or most recent first
    -All                        Console only: show every crash, not just 20
    -NoPause                    Console only: don't wait for Enter at the end
#>
param(
    [ValidateRange(1, 90)] [int]$Days = 14,
    [ValidateSet('Severity', 'Recent')] [string]$SortBy = 'Severity',
    [switch]$Console,
    [switch]$All,
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'
$script:Version = '0.2.0'

foreach ($module in 'Collect', 'Explain', 'Report') {
    . (Join-Path $PSScriptRoot "modules\$module.ps1")
}

# ------------------------------------------------------------------
#  Window (default)
# ------------------------------------------------------------------

if (-not $Console) {
    try {
        Import-Rules (Join-Path $PSScriptRoot 'rules')
        . (Join-Path $PSScriptRoot 'modules\Ui.ps1')
        Show-CrashWindow -Root $PSScriptRoot -Version $script:Version -Days $Days -SortBy $SortBy
    } catch {
        # The launcher hides the console, so errors must be shown in a message box
        Add-Type -AssemblyName PresentationFramework
        [System.Windows.MessageBox]::Show("Crash Explainer could not start:`n$($_.Exception.Message)", 'Crash Explainer', 'OK', 'Error') | Out-Null
    }
    return
}

# ------------------------------------------------------------------
#  Console
# ------------------------------------------------------------------

try {
    Import-Rules (Join-Path $PSScriptRoot 'rules')
    Write-Host ''
    Write-Host ' Reading Windows crash logs...' -ForegroundColor DarkGray
    Show-Report -Report (Get-CrashReport -Days $Days) -SortBy $SortBy -All:$All
} catch {
    Write-Host ''
    Write-Host " Something went wrong: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
}

if (-not $NoPause) {
    Write-Host ''
    Read-Host ' Press Enter to close' | Out-Null
}
