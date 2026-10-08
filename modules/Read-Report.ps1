<#
    Reads and explains the crashes in the background for the window.
    The window starts this script in a separate runspace (a second
    PowerShell inside the same program), so it never freezes while the
    logs are read, and gets progress and the result through Queue:

      Progress  Label = what is being read, Percent = 0-100
      Done      Report = the result of Get-CrashReport
      Error     Message = what went wrong

    Read-only, like everything else in this tool.
#>
param(
    [string]$Root,
    [int]$Days,
    $Queue
)

$ErrorActionPreference = 'Stop'

try {
    foreach ($module in 'Collect', 'Explain') { . (Join-Path $Root "modules\$module.ps1") }
    Import-Rules (Join-Path $Root 'rules')

    # Every source, plus explaining at the end
    $progress = @{ Step = 0; Total = $script:CrashSources.Count + 1 }
    $onStep = {
        param([string]$Label)
        $Queue.Enqueue([pscustomobject]@{ Type = 'Progress'; Label = $Label; Percent = 100 * $progress.Step / $progress.Total })
        $progress.Step++
    }.GetNewClosure()

    $report = Get-CrashReport -Days $Days -OnStep $onStep
    $Queue.Enqueue([pscustomobject]@{ Type = 'Done'; Report = $report })
} catch {
    $Queue.Enqueue([pscustomobject]@{ Type = 'Error'; Message = $_.Exception.Message })
}
