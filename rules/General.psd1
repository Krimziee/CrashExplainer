# Explanations that don't come from a code or a file name: sudden
# shutdowns, freezes, graphics driver resets, hardware (WHEA) errors,
# unknown codes, and the "big picture" notes.
@{
    PowerLoss = @{
        Title    = 'The PC turned off without shutting down properly'
        Category = 'Power'
        Explain  = 'Windows did not get to shut down and saved no crash report. That usually points at power or hardware rather than software: the power supply, a loose cable, overheating, or a very unstable overclock. A power cut, pulling the plug or pressing the reset button looks the same.'
        Fixes    = @(
            'If there was a power cut, or you switched off at the wall or pressed reset, you can ignore this one.'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            'Check the power cables to the motherboard and graphics card. If the PC turns off during heavy games, the power supply may be too weak or failing.'
        )
    }
    PowerButton = @{
        Title    = 'The PC was turned off with the power button'
        Category = 'Power'
        Explain  = 'Windows saw the power button being pressed or held down while it was running. If you did that because the PC had frozen, the freeze is the real problem.'
        Fixes    = @(
            'If the PC had frozen, note what you were doing. Freezes are often the graphics driver, overheating or unstable overclock settings.'
            'Look at the other entries in this report from around the same time.'
        )
    }
    GpuReset = @{
        Title    = 'Graphics driver stopped responding and recovered'
        Category = 'Gpu'
        Explain  = 'Your screen probably went black or flickered for a moment. Windows restarted the graphics driver because the graphics card stopped responding.'
        Fixes    = @(
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            'Make sure the graphics card power cables are firmly plugged in - ideally separate cables from the power supply, not one split cable.'
        )
    }
    AppHang = @{
        Explain = 'The program stopped responding and was closed, by you or by Windows. Freezes usually mean the program was stuck waiting for something: the drive, the network or the graphics card.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
            'Check your drive''s health with CrystalDiskInfo.'
        )
    }
    AppOwnCode = @{
        Component = 'the program itself'
        Category  = 'App'
        Explain   = 'The crash happened inside the program''s own code, not in a driver or add-on.'
        Fixes     = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Remove mods, then add them back one at a time to find the one causing it.'
        )
    }
    ReplacedWindowsFile = @{
        # Windows file names that mods, ReShade and mod loaders put in game folders
        Names     = @('dxgi.dll', 'd3d8.dll', 'd3d9.dll', 'd3d10.dll', 'd3d11.dll', 'd3d12.dll', 'dinput8.dll', 'opengl32.dll',
                      'version.dll', 'winmm.dll', 'winhttp.dll', 'xinput1_3.dll', 'xinput1_4.dll', 'dsound.dll')
        Component = 'a mod or ReShade (a replacement for a Windows file)'
        Category  = 'Mod'
        Explain   = 'The file that crashed has a Windows name but was not loaded from the Windows folder. That usually means a mod, ReShade, a mod loader or a "fix" pack put its own copy next to the game.'
        Fixes     = @(
            'Remove or update the mod, ReShade or loader that put this file in the game folder, then test again.'
            'Remove mods, then add them back one at a time to find the one causing it.'
        )
    }
    AddOnInWindowsProgram = @{
        Component = 'add-on from another program'
        Category  = 'AddOn'
        Explain   = 'A Windows program crashed inside a file that does not belong to Windows. Other programs add their own files to Explorer and other Windows programs (right-click menus, cloud sync icons, overlays), and one of them most likely caused this. The folder below shows which program it came from.'
        Fixes     = @(
            'Update the program this file belongs to (see the folder above), or uninstall it if you do not use it.'
            'For Explorer crashes, ShellExView (NirSoft) can turn off add-ons one at a time to find the bad one.'
        )
    }
    WindowsProgram = @{
        # Fixes used instead of the game-oriented ones when the crashed program is part of Windows
        Fixes = @(
            'Install the latest Windows updates.'
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
        )
    }
    UnknownException = @{
        Explain = 'This error code is not in Crash Explainer''s list yet.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
        )
    }
    UnknownBlueScreen = @{
        Explain = 'This blue screen code is not in Crash Explainer''s list yet. Blue screens are usually caused by a driver, unstable hardware settings, or failing hardware.'
        Fixes   = @(
            'Update your chipset, network and graphics drivers from the manufacturers'' websites.'
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            'Repair Windows files: in an admin Command Prompt run "sfc /scannow", then "DISM /Online /Cleanup-Image /RestoreHealth".'
        )
    }

    # WHEA-Logger event ids. 'Hardware' counts toward the big picture note;
    # corrected errors are 'HardwareMinor' so a few harmless ones don't trigger it.
    Whea = @{
        '1' = @{
            Title    = 'fatal hardware error'
            Category = 'Hardware'
            Explain  = 'The hardware reported an error it could not correct, which crashed the PC. Usually instability from overclocking, undervolting, heat or an outdated BIOS.'
            Fixes    = @(
                'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
                'Update your BIOS, following your motherboard maker''s instructions exactly. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
                'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            )
        }
        '18' = @{
            Title    = 'fatal CPU error'
            Category = 'Hardware'
            Explain  = 'The CPU reported an error it could not correct, which crashed the PC. Usually instability from overclocking, undervolting, heat or an outdated BIOS.'
            Fixes    = @(
                'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
                'Update your BIOS, following your motherboard maker''s instructions exactly. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
                'Check CPU and GPU temperatures while gaming (for example with HWiNFO), and clean out dust.'
            )
        }
        '19' = @{
            Title    = 'corrected CPU error'
            Category = 'HardwareMinor'
            Explain  = 'The CPU reported a small error that it corrected. A few are harmless, but many of them mean the CPU or RAM is close to unstable - often from an overclock, undervolt or Curve Optimizer setting.'
            Fixes    = @(
                'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
                'Update your BIOS, following your motherboard maker''s instructions exactly. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
            )
        }
        '17' = @{
            Title    = 'corrected PCIe error'
            Category = 'HardwareMinor'
            Explain  = 'A device in a PCIe slot (graphics card, NVMe SSD, Wi-Fi card) had a communication error that was corrected. Usually harmless, but it can come with stutters or crashes.'
            Fixes    = @(
                'With the PC off and unplugged, take the device out and push it firmly back into its slot.'
                'Update your chipset drivers, and your BIOS (following your motherboard maker''s instructions exactly).'
                'If you use a PCIe riser cable, set the slot to Gen 3 or Gen 4 in the BIOS instead of Auto.'
            )
        }
        '47' = @{
            Title    = 'corrected memory error'
            Category = 'HardwareMinor'
            Explain  = 'The RAM had a small error that was corrected. Repeated ones mean the RAM is unstable or failing.'
            Fixes    = @(
                'Turn off XMP/EXPO (the RAM overclock) in the BIOS for a few days and see if the crashes stop.'
                'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
            )
        }
        Other = @{
            Title    = 'hardware warning'
            Category = 'HardwareMinor'
            Explain  = 'The hardware reported a problem. On its own this may be harmless; it matters if it happens often or near crashes.'
            Fixes    = @(
                'Update your chipset drivers, and your BIOS (following your motherboard maker''s instructions exactly).'
                'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            )
        }
    }

    # {0}, {1} are filled in by Get-BigPicture in Explain.ps1
    BigPicture = @{
        Hardware          = 'Your hardware reported serious errors. Before anything else, turn off overclocks and undervolts (XMP/EXPO, PBO, Curve Optimizer) and update your BIOS - that solves many of these cases.'
        ManyBlueScreens   = 'You had {0} different kinds of blue screen. Different blue screens often share one cause - unstable RAM, an overclock or one bad driver - so test your RAM and settings first.'
        Gpu               = 'The graphics driver or graphics card is involved in {0} of these events. A clean driver install (DDU) and removing GPU overclocks is the best place to start.'
        Overlay           = 'Overlays ({0}) show up in crashes of several programs. Turn them off and see if the crashes stop.'
        SameErrorManyApps = '{0} different programs crashed with the same error ({1}). When unrelated programs fail the same way, look at the PC (CPU and RAM stability, drivers) rather than each program.'
        Power             = 'The PC turned off without warning {0} times. Repeated sudden shutdowns usually point to the power supply, overheating or an unstable overclock.'
    }
}
