<#
    The Crash Explainer tab in Krimz's Toolkit. The toolkit loads this file in
    its own private module and calls the functions below. The page is the same
    one the standalone window shows (ui\Page.xaml, built by Ui.ps1).
    Read-only, like everything else in this tool. Inside the toolkit it runs
    with admin rights only because the toolkit does; it never asks for them.
#>

foreach ($module in 'Collect', 'Explain') { . (Join-Path $PSScriptRoot "$module.ps1") }
. (Join-Path $PSScriptRoot 'Ui.ps1')

function New-ToolPage {
    param([string]$Root, [hashtable]$Shell)
    # The version is the one in CrashExplainer.ps1 (read from the file, nothing is run)
    $version = if ((Get-Content (Join-Path $Root 'CrashExplainer.ps1') -Raw) -match "\`$script:Version = '([^']+)'") { $Matches[1] }
    New-CrashPage -Root $Root -Version $version -OnBusy $Shell.SetBusy
}

# The logs are read the first time the tab is opened; Refresh and the period read them again
function Enter-ToolPage { Start-CrashPage }

function Close-ToolPage { Stop-Reading }
