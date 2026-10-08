# Program crash (exception) codes from "Application Error" events.
# Keys are 8 uppercase hex digits without '0x'.
# The file the crash happened in (Modules.psd1) usually matters more than
# this code; its fixes are listed first.
@{
    'C0000005' = @{
        Name    = 'access violation'
        Explain = 'The program tried to use memory it was not allowed to touch. This is the most common crash and has many causes - the file it happened in (below) says more than this code.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
        )
    }
    'C0000409' = @{
        Name    = 'stack buffer overrun'
        Explain = 'The program detected a serious problem - often damaged memory - and shut itself down on purpose. Usually a bug in the program, but if several different games crash this way, an unstable CPU or RAM is likely.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Update your BIOS, following your motherboard maker''s instructions exactly. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
        )
    }
    'C0000374' = @{
        Name    = 'heap corruption'
        Explain = 'The program damaged its own memory. Usually a bug in the program or a mod, sometimes unstable RAM.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Remove mods, then add them back one at a time to find the one causing it.'
            'Test your RAM: run "Windows Memory Diagnostic" from the Start menu, or MemTest86 for a deeper test.'
        )
    }
    'C00000FD' = @{
        Name    = 'stack overflow'
        Explain = 'The program ran out of a small, fixed piece of memory, usually because of a bug that keeps repeating itself.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Remove mods, then add them back one at a time to find the one causing it.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
        )
    }
    'C000001D' = @{
        Name     = 'illegal instruction'
        Category = 'Stability'
        Explain  = 'The CPU was given an instruction it could not run. Usually either your CPU is too old for this program (for example, it has no AVX support), or the CPU is unstable.'
        Fixes    = @(
            'Check that your CPU meets the game''s minimum requirements.'
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
            'Update your BIOS, following your motherboard maker''s instructions exactly. Intel 13th/14th gen CPUs especially need a recent BIOS to stay stable.'
        )
    }
    'C0000096' = @{
        Name     = 'privileged instruction'
        Category = 'Stability'
        Explain  = 'The program tried to run a CPU instruction that only Windows itself may use. Usually damaged program files or an unstable CPU.'
        Fixes    = @(
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Turn off all overclocks and undervolts: XMP/EXPO, PBO, Curve Optimizer, Intel XTU - or load the BIOS defaults - and see if the crashes stop.'
        )
    }
    'C0000006' = @{
        Name     = 'in-page error'
        Category = 'Disk'
        Explain  = 'Part of the program could not be read from the drive while it was running. The drive may be failing, or the program was on a USB drive or network share that disconnected.'
        Fixes    = @(
            'Check your drive''s health with CrystalDiskInfo.'
            'Move the game to an internal drive if it is on a USB drive or network share.'
            'Check the drive for errors: in an admin Command Prompt run "chkdsk C: /scan".'
        )
    }
    'C0000142' = @{
        Name    = 'DLL initialization failed'
        Explain = 'A part of the program (a DLL file) failed to start. Often damaged files or a missing Visual C++ runtime.'
        Fixes   = @(
            'Reinstall the latest Microsoft Visual C++ Redistributable (both x64 and x86).'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Restart the PC and try again.'
        )
    }
    'E06D7363' = @{
        Name    = 'unhandled C++ exception'
        Explain = 'The program hit an error in its own code that it did not handle. Usually a program bug, or damaged or missing game files.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Reinstall the latest Microsoft Visual C++ Redistributable (both x64 and x86).'
        )
    }
    'E0434352' = @{
        Name    = 'unhandled .NET exception'
        Explain = 'A program written in .NET hit an error it did not handle. The program''s own log or error message usually says more.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Install the latest Windows updates.'
            'Reinstall the program.'
        )
    }
    '80000003' = @{
        Name    = 'breakpoint'
        Explain = 'The program stopped itself on purpose because something unexpected happened. Some anti-cheat software and game engines do this.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            'Repair the anti-cheat: most games have an EasyAntiCheat or BattlEye folder with a setup file that has a Repair option.'
        )
    }
    '40000015' = @{
        Name    = 'abort'
        Explain = 'The program decided it could not continue and closed itself. Usually a program bug or damaged files.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
        )
    }
    'C0000602' = @{
        Name    = 'fail fast'
        Explain = 'The program found a serious problem and closed itself immediately. Usually a program bug.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
        )
    }
    'C0000420' = @{
        Name    = 'assertion failure'
        Explain = 'One of the program''s own safety checks failed, so it stopped. A program bug.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
        )
    }
    'C0000417' = @{
        Name    = 'invalid runtime parameter'
        Explain = 'The program passed bad data to the Visual C++ runtime. A program bug, or a damaged runtime.'
        Fixes   = @(
            'Update the game or app to its latest version.'
            'Reinstall the latest Microsoft Visual C++ Redistributable (both x64 and x86).'
        )
    }
    'C000027B' = @{
        Name    = 'Store app error'
        Explain = 'An app built like a Microsoft Store app (including Game Bar widgets) hit an error it did not handle. Usually a bug in the app.'
        Fixes   = @(
            'Update the app from the Microsoft Store (Library > Get updates).'
            'Repair or reset the app: Settings > Apps > Installed apps > the app > Advanced options.'
            'Uninstall the app if you do not use it.'
        )
    }
    'C000041D' = @{
        Name    = 'error during a Windows callback'
        Explain = 'An error happened while Windows was handing something (often window or input events) to the program. Overlays are a common cause.'
        Fixes   = @(
            'Turn off overlays (Discord, Steam, NVIDIA app, MSI Afterburner/RTSS) and try again.'
            'Update the game or app to its latest version.'
        )
    }
}
