# Blue screen (bug check) codes. Keys are the code as Collect.ps1 writes
# it: '0x' + uppercase hex with no leading zeros ('0x116', not '0x00000116').
# Category feeds "The big picture": Hardware, Memory, Driver, Gpu, Disk, System.
# Fixes go easiest first. Keep fix wording identical to the same fix in
# other rule files, so duplicates are merged in the report.
@{
    '0xA' = @{
        Name     = 'IRQL_NOT_LESS_OR_EQUAL'
        Category = 'Driver'
        Explain  = 'A driver (or Windows itself) tried to use memory it was not allowed to touch. Usually a faulty or outdated driver, sometimes unstable RAM.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Turn off XMP/EXPO (the RAM overclock) in the BIOS for a few days and see if the crashes stop.'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
        )
    }
    '0xD1' = @{
        Name     = 'DRIVER_IRQL_NOT_LESS_OR_EQUAL'
        Category = 'Driver'
        Explain  = 'A driver tried to use memory it was not allowed to touch. Network, Wi-Fi, audio and graphics drivers are the usual suspects.'
        Fixes    = @(
            'Update your network and Wi-Fi drivers from your motherboard or laptop maker''s website.'
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Uninstall VPN, network-monitoring or "game booster" software you do not need.'
        )
    }
    '0x1A' = @{
        Name     = 'MEMORY_MANAGEMENT'
        Category = 'Memory'
        Explain  = 'Windows found that its memory bookkeeping was damaged. This is very often faulty or unstable RAM.'
        Fixes    = @(
            'Turn off XMP/EXPO (the RAM overclock) in the BIOS for a few days and see if the crashes stop.'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
            'Reseat the RAM sticks, or test with one stick at a time to find a bad one.'
            'Update your BIOS. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
        )
    }
    '0x50' = @{
        Name     = 'PAGE_FAULT_IN_NONPAGED_AREA'
        Category = 'Memory'
        Explain  = 'Windows tried to read memory that should always be there, and it was not. Caused by faulty RAM, a bad driver, or sometimes antivirus software.'
        Fixes    = @(
            'Turn off XMP/EXPO (the RAM overclock) in the BIOS for a few days and see if the crashes stop.'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Uninstall third-party antivirus to test - Windows Security is enough for most people.'
        )
    }
    '0x3B' = @{
        Name     = 'SYSTEM_SERVICE_EXCEPTION'
        Category = 'Driver'
        Explain  = 'A driver made an error while Windows was handling a request for it. Graphics drivers and anti-cheat drivers are common causes.'
        Fixes    = @(
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
        )
    }
    '0x7E' = @{
        Name     = 'SYSTEM_THREAD_EXCEPTION_NOT_HANDLED'
        Category = 'Driver'
        Explain  = 'A driver hit an error it did not handle, so Windows had to stop.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Think about what you installed or updated just before the crashes started, and undo it (System Restore can help).'
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
        )
    }
    '0x1E' = @{
        Name     = 'KMODE_EXCEPTION_NOT_HANDLED'
        Category = 'Driver'
        Explain  = 'A driver hit an error it did not handle, so Windows had to stop. Usually a faulty driver, sometimes unstable RAM or CPU.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Think about what you installed or updated just before the crashes started, and undo it (System Restore can help).'
            'Turn off XMP/EXPO (the RAM overclock) in the BIOS for a few days and see if the crashes stop.'
        )
    }
    '0x7F' = @{
        Name     = 'UNEXPECTED_KERNEL_MODE_TRAP'
        Category = 'Hardware'
        Explain  = 'The CPU hit an error Windows could not recover from. Often hardware instability (overclock, undervolt, heat), sometimes a bad driver.'
        Fixes    = @(
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
        )
    }
    '0x9F' = @{
        Name     = 'DRIVER_POWER_STATE_FAILURE'
        Category = 'Driver'
        Explain  = 'A device did not respond when Windows put the PC to sleep or woke it up. Usually a Wi-Fi, USB, graphics or chipset driver.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Turn off Fast Startup: Control Panel > Power Options > Choose what the power buttons do.'
            'Unplug USB devices you do not need and see if it stops.'
        )
    }
    '0x116' = @{
        Name     = 'VIDEO_TDR_FAILURE'
        Category = 'Gpu'
        Explain  = 'Your graphics card stopped responding and Windows could not restart it.'
        Fixes    = @(
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            'Make sure the graphics card power cables are firmly plugged in - ideally separate cables from the power supply, not one split cable.'
        )
    }
    '0x117' = @{
        Name     = 'VIDEO_TDR_TIMEOUT_DETECTED'
        Category = 'Gpu'
        Explain  = 'Your graphics card stopped responding. Windows managed to restart it this time.'
        Fixes    = @(
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
        )
    }
    '0x119' = @{
        Name     = 'VIDEO_SCHEDULER_INTERNAL_ERROR'
        Category = 'Gpu'
        Explain  = 'The part of Windows that hands work to your graphics card found something wrong. Usually the graphics driver.'
        Fixes    = @(
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            'Install the latest Windows updates.'
        )
    }
    '0xEA' = @{
        Name     = 'THREAD_STUCK_IN_DEVICE_DRIVER'
        Category = 'Gpu'
        Explain  = 'A driver - almost always the graphics driver - got stuck waiting for the graphics card.'
        Fixes    = @(
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            'Make sure the graphics card power cables are firmly plugged in - ideally separate cables from the power supply, not one split cable.'
        )
    }
    '0x124' = @{
        Name     = 'WHEA_UNCORRECTABLE_ERROR'
        Category = 'Hardware'
        Explain  = 'Your hardware itself reported an error it could not fix - usually the CPU, RAM or motherboard. Most often caused by overclocking, undervolting or heat, not by a broken part.'
        Fixes    = @(
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            'Update your BIOS. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            'If it still happens at default settings, the power supply, RAM or CPU may be failing.'
        )
    }
    '0x101' = @{
        Name     = 'CLOCK_WATCHDOG_TIMEOUT'
        Category = 'Hardware'
        Explain  = 'One of your CPU cores stopped responding. Almost always CPU instability from overclocking, undervolting or an outdated BIOS.'
        Fixes    = @(
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            'Update your BIOS. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
        )
    }
    '0x133' = @{
        Name     = 'DPC_WATCHDOG_VIOLATION'
        Category = 'Driver'
        Explain  = 'A driver took far too long to finish its work. Often the SSD''s driver or firmware, sometimes another driver.'
        Fixes    = @(
            'Update your SSD''s firmware with its maker''s tool (Samsung Magician, WD Dashboard, Crucial Storage Executive...).'
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Think about what you installed or updated just before the crashes started, and undo it (System Restore can help).'
        )
    }
    '0x139' = @{
        Name     = 'KERNEL_SECURITY_CHECK_FAILURE'
        Category = 'Driver'
        Explain  = 'Windows found that some of its internal data was damaged and stopped to protect itself. Usually a faulty driver, sometimes RAM.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
        )
    }
    '0x19' = @{
        Name     = 'BAD_POOL_HEADER'
        Category = 'Driver'
        Explain  = 'A driver damaged a block of memory that Windows manages. Usually a faulty driver, sometimes antivirus software or RAM.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Uninstall third-party antivirus to test - Windows Security is enough for most people.'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
        )
    }
    '0xC2' = @{
        Name     = 'BAD_POOL_CALLER'
        Category = 'Driver'
        Explain  = 'A driver asked Windows for memory in a wrong way. Usually a faulty driver, sometimes antivirus software.'
        Fixes    = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Uninstall third-party antivirus to test - Windows Security is enough for most people.'
            'Think about what you installed or updated just before the crashes started, and undo it (System Restore can help).'
        )
    }
    '0x109' = @{
        Name     = 'CRITICAL_STRUCTURE_CORRUPTION'
        Category = 'Driver'
        Explain  = 'Windows found that its core code or data had been changed. Usually a driver that patches Windows (old tuning, RGB or cheat tools), or faulty RAM.'
        Fixes    = @(
            'Uninstall old system-tuning, RGB or hardware-monitoring tools you no longer use.'
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
        )
    }
    '0xEF' = @{
        Name     = 'CRITICAL_PROCESS_DIED'
        Category = 'System'
        Explain  = 'A process Windows cannot live without stopped unexpectedly. Often damaged system files or a failing drive.'
        Fixes    = @(
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
            'Check your drive''s health with CrystalDiskInfo.'
            'Think about what you installed or updated just before the crashes started, and undo it (System Restore can help).'
        )
    }
    '0xC000021A' = @{
        Name     = 'STATUS_SYSTEM_PROCESS_TERMINATED'
        Category = 'System'
        Explain  = 'A core Windows process (the one that handles sign-in, or the one that runs programs'' windows) stopped. Usually damaged system files, or a recent update or driver.'
        Fixes    = @(
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
            'Think about what you installed or updated just before the crashes started, and undo it (System Restore can help).'
            'Check your drive''s health with CrystalDiskInfo.'
        )
    }
    '0x7A' = @{
        Name     = 'KERNEL_DATA_INPAGE_ERROR'
        Category = 'Disk'
        Explain  = 'Windows could not read data it needed from the drive. A failing drive, a loose cable or bad RAM.'
        Fixes    = @(
            'Check your drive''s health with CrystalDiskInfo.'
            'For SATA drives, reseat or replace the SATA cable.'
            'Check the drive for errors: in an admin Command Prompt run "chkdsk C: /scan".'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
        )
    }
    '0x154' = @{
        Name     = 'UNEXPECTED_STORE_EXCEPTION'
        Category = 'Disk'
        Explain  = 'Something went wrong with memory that Windows keeps on the drive. Usually drive problems, sometimes antivirus software.'
        Fixes    = @(
            'Check your drive''s health with CrystalDiskInfo.'
            'Update your SSD''s firmware with its maker''s tool (Samsung Magician, WD Dashboard, Crucial Storage Executive...).'
            'Uninstall third-party antivirus to test - Windows Security is enough for most people.'
        )
    }
    '0x24' = @{
        Name     = 'NTFS_FILE_SYSTEM'
        Category = 'Disk'
        Explain  = 'A problem reading or writing files on the drive. Damaged file system or a failing drive.'
        Fixes    = @(
            'Check the drive for errors: in an admin Command Prompt run "chkdsk C: /scan".'
            'Check your drive''s health with CrystalDiskInfo.'
            'For SATA drives, reseat or replace the SATA cable.'
        )
    }
}
