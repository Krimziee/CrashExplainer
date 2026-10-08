<#
    Reads the crash records Windows already keeps in its event logs and
    turns each one into a simple crash object. Read-only.

    Every crash has the same fields:
      Kind        BlueScreen | SuddenShutdown | Hardware | GpuReset | AppCrash | AppHang
      Time        When it happened
      App         Program name (AppCrash / AppHang)
      Module      The file the crash happened in, the graphics driver (GpuReset)
                  or the device (Hardware)
      ModulePath  Full path of Module, when Windows recorded it
      AppPath     Full path of the program (AppCrash / AppHang)
      Code        Bug check code ('0x116'), exception code ('C0000005'),
                  WHEA event id ('19'), or 'PowerLoss' / 'PowerButton'
      Detail      One extra line for the report (program path...)
#>

function Read-EventLog {
    param([hashtable]$Filter)
    try {
        Get-WinEvent -FilterHashtable $Filter -ErrorAction Stop
    } catch {
        # Get-WinEvent reports "nothing found" as an error
        if ($_.FullyQualifiedErrorId -notlike 'NoMatchingEventsFound*') {
            Write-Warning ('Could not read the {0} log: {1}' -f $Filter.LogName, $_.Exception.Message)
        }
    }
}

function Get-EventFields {
    # Returns the event's data fields by name, and also by position ('0', '1', ...)
    # because older events and some providers leave the fields unnamed
    param($Record)
    $fields = @{}
    $data = ([xml]$Record.ToXml()).Event.EventData
    if ($data -isnot [System.Xml.XmlElement]) { return $fields }
    $i = 0
    foreach ($node in $data.SelectNodes('*')) {
        $fields["$i"] = $node.InnerText
        $name = $node.GetAttribute('Name')
        if ($name) { $fields[$name] = $node.InnerText }
        $i++
    }
    $fields
}

function Get-Field {
    # First non-empty field out of several possible names
    param([hashtable]$Fields, [string[]]$Keys)
    foreach ($key in $Keys) {
        if ($Fields.ContainsKey($key) -and $Fields[$key]) { return $Fields[$key] }
    }
    ''
}

function ConvertTo-BugCheckCode {
    # '0x1000007e', '0x0000007E' and 126 all become '0x7E'.
    # The 0x10000000 flag marks the same kind of crash, so it is removed.
    param($Value)
    if ("$Value" -match '^0x([0-9a-f]+)$') { $number = [Convert]::ToUInt64($Matches[1], 16) }
    else { $number = [UInt64]$Value }
    if ($number -ge 0x10000000 -and $number -lt 0x11000000) { $number -= 0x10000000 }
    '0x{0:X}' -f $number
}

function ConvertTo-ExceptionCode {
    # 'c0000005' and '0xc0000005' both become 'C0000005'
    param([string]$Value)
    ($Value -replace '^0x', '').ToUpper().PadLeft(8, '0')
}

function New-Crash {
    param([string]$Kind, [datetime]$Time, [string]$App = '', [string]$Module = '',
          [string]$ModulePath = '', [string]$AppPath = '', [string]$Code = '', [string]$Detail = '')
    [pscustomobject]@{
        Kind = $Kind; Time = $Time; App = $App; Module = $Module
        ModulePath = $ModulePath; AppPath = $AppPath; Code = $Code; Detail = $Detail
    }
}

function Get-PathField {
    # Paths can be recorded as 'unknown', or with a \\?\ long-path prefix
    param([hashtable]$Fields, [string[]]$Keys)
    $path = (Get-Field $Fields $Keys) -replace '^\\\\\?\\', ''
    if ($path -like '*\*') { $path } else { '' }
}

# What Get-CrashEvents reads, in order; the window shows these while reading
$script:CrashSources = 'Blue screens', 'Unexpected shutdowns', 'Graphics driver resets', 'Hardware errors', 'Program crashes', 'Program freezes'

function Get-CrashEvents {
    # -OnStep is called with the name of each source before it is read (progress in the window)
    param([datetime]$Since, [scriptblock]$OnStep = {})
    $crashes = New-Object System.Collections.Generic.List[object]

    # Blue screens: logged after the restart, with the bug check code and parameters
    & $OnStep $script:CrashSources[0]
    $blueScreens = @(Read-EventLog @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'; Id = 1001; StartTime = $Since })
    foreach ($record in $blueScreens) {
        $fields = Get-EventFields $record
        if ((Get-Field $fields 'param1', '0') -notmatch '(0x[0-9a-fA-F]+)') { continue }
        $crashes.Add((New-Crash -Kind BlueScreen -Time $record.TimeCreated -Code (ConvertTo-BugCheckCode $Matches[1])))
    }

    # Kernel-Power 41: Windows started again without having shut down properly
    & $OnStep $script:CrashSources[1]
    foreach ($record in @(Read-EventLog @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 41; StartTime = $Since })) {
        $fields = Get-EventFields $record
        $bugCheck = Get-Field $fields 'BugcheckCode', '0'
        if ($bugCheck -and $bugCheck -ne '0') {
            # A blue screen. Windows usually also saved a report (above); only
            # count this one when it didn't, so the same crash isn't listed twice.
            $reported = $blueScreens | Where-Object { [Math]::Abs(($_.TimeCreated - $record.TimeCreated).TotalMinutes) -lt 30 }
            if (-not $reported) {
                $crashes.Add((New-Crash -Kind BlueScreen -Time $record.TimeCreated -Code (ConvertTo-BugCheckCode $bugCheck) `
                                        -Detail 'No crash report was saved for this one.'))
            }
            continue
        }
        $button = (Get-Field $fields 'PowerButtonTimestamp') -notin '', '0' -or
                  (Get-Field $fields 'LongPowerButtonPressDetected') -eq 'true'
        $crashes.Add((New-Crash -Kind SuddenShutdown -Time $record.TimeCreated -Code $(if ($button) { 'PowerButton' } else { 'PowerLoss' })))
    }

    # Graphics driver stopped responding and was restarted (screen goes black for a moment)
    & $OnStep $script:CrashSources[2]
    foreach ($record in @(Read-EventLog @{ LogName = 'System'; ProviderName = 'Display'; Id = 4101; StartTime = $Since })) {
        $fields = Get-EventFields $record
        $crashes.Add((New-Crash -Kind GpuReset -Time $record.TimeCreated -Module (Get-Field $fields '0') -Code '4101'))
    }

    # Errors the hardware itself reported (CPU, RAM, PCIe)
    & $OnStep $script:CrashSources[3]
    foreach ($record in @(Read-EventLog @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; Level = 1, 2, 3; StartTime = $Since })) {
        $fields = Get-EventFields $record
        $crashes.Add((New-Crash -Kind Hardware -Time $record.TimeCreated -Code "$($record.Id)" `
                                -Module (Get-Field $fields 'PrimaryDeviceName', 'DeviceName')))
    }

    # Program crashes
    & $OnStep $script:CrashSources[4]
    foreach ($record in @(Read-EventLog @{ LogName = 'Application'; ProviderName = 'Application Error'; Id = 1000; StartTime = $Since })) {
        $fields = Get-EventFields $record
        $module = Get-Field $fields 'ModuleName', '3'
        if ($module -eq 'unknown') { $module = '' }
        $appPath = Get-PathField $fields 'AppPath', '10'
        $crashes.Add((New-Crash -Kind AppCrash -Time $record.TimeCreated `
                                -App (Get-Field $fields 'AppName', '0') -AppPath $appPath `
                                -Module $module -ModulePath (Get-PathField $fields 'ModulePath', '11') `
                                -Code (ConvertTo-ExceptionCode (Get-Field $fields 'ExceptionCode', '6')) `
                                -Detail $(if ($appPath) { "Program: $appPath" })))
    }

    # Program freezes ("not responding", then closed)
    & $OnStep $script:CrashSources[5]
    foreach ($record in @(Read-EventLog @{ LogName = 'Application'; ProviderName = 'Application Hang'; Id = 1002; StartTime = $Since })) {
        $fields = Get-EventFields $record
        $appPath = Get-PathField $fields 'ExeFileName', '5'
        $crashes.Add((New-Crash -Kind AppHang -Time $record.TimeCreated -App (Get-Field $fields 'AppName', '0') -AppPath $appPath `
                                -Detail $(if ($appPath) { "Program: $appPath" })))
    }

    $crashes.ToArray()
}
