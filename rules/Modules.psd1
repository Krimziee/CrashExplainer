# Files a crash can happen in, matched by name with wildcards (* and ?),
# not case-sensitive. The first matching rule wins, so put specific
# patterns before general ones.
# Category feeds "The big picture": Gpu, Overlay, AntiCheat, Mod, Windows,
# Runtime, Engine, Audio, Launcher.
@{
    Modules = @(
        @{
            Match     = @('nvlddmkm*', 'nvwgf2um*', 'nvd3dum*', 'nvoglv*', 'nvgpucomp*', 'nvcuda*', 'nvapi*', 'nvldumd*', 'nvrtum*')
            Component = 'NVIDIA graphics driver'
            Category  = 'Gpu'
            Explain   = 'The crash happened inside the NVIDIA graphics driver.'
            Fixes     = @(
                'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
                'If the crashes started after a driver update, go back to the driver version you had before.'
                'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            )
        }
        @{
            Match     = @('atikmdag*', 'amdkmdag*', 'atidxx*', 'amdxx*', 'atiumd*', 'amdvlk*', 'atio6axx*', 'atiadlxx*', 'amdxc*', 'amdihk*', 'amdenc*')
            Component = 'AMD graphics driver'
            Category  = 'Gpu'
            Explain   = 'The crash happened inside the AMD graphics driver.'
            Fixes     = @(
                'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
                'If the crashes started after a driver update, go back to the driver version you had before.'
                'Remove any GPU overclock or undervolt (MSI Afterburner, AMD Adrenalin tuning, NVIDIA app).'
            )
        }
        @{
            Match     = @('igdkmd*', 'igd10*', 'igd12*', 'igdumd*', 'igc64*', 'igxel*', 'igvk*', 'igdail*')
            Component = 'Intel graphics driver'
            Category  = 'Gpu'
            Explain   = 'The crash happened inside the Intel graphics driver.'
            Fixes     = @(
                'Install the latest Intel graphics driver (or the one from your laptop maker).'
                'On a laptop with an NVIDIA or AMD card too, make the game use that card: Settings > System > Display > Graphics.'
            )
        }
        @{
            Match     = @('nvngx*', 'amd_fidelityfx*', 'ffx_*', 'libxess*', 'sl.*')
            Component = 'upscaler / frame generation (DLSS, FSR, XeSS)'
            Category  = 'Gpu'
            Explain   = 'The crash happened inside an upscaling or frame generation feature.'
            Fixes     = @(
                'Turn off DLSS/FSR/XeSS and frame generation in the game and see if the crashes stop.'
                'If you replaced the DLSS file yourself (DLSS Swapper or similar), put the original back.'
                'Update the game or app to its latest version.'
            )
        }
        @{
            Match     = @('d3d11.dll', 'd3d12.dll', 'd3d12core.dll', 'dxgi.dll', 'd3d9.dll', 'dxcore.dll', 'd3dcompiler_*')
            Component = 'DirectX (Windows graphics)'
            Category  = 'Gpu'
            Explain   = 'DirectX is the part of Windows that talks to your graphics driver. The real cause is usually the graphics driver, an overlay or the game itself.'
            Fixes     = @(
                'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
                'Turn off overlays (Discord, Steam, NVIDIA app, MSI Afterburner/RTSS) and try again.'
                'Try the game''s DirectX 11 mode if it has one, or lower the graphics settings.'
            )
        }
        @{
            Match     = @('vulkan-1.dll')
            Component = 'Vulkan (graphics)'
            Category  = 'Gpu'
            Explain   = 'Vulkan is a way for games to talk to your graphics driver. The real cause is usually the graphics driver or an overlay.'
            Fixes     = @(
                'Clean-install your graphics driver: remove it with DDU (Display Driver Uninstaller), then install the latest driver.'
                'Turn off overlays (Discord, Steam, NVIDIA app, MSI Afterburner/RTSS) and try again.'
                'Try the game''s DirectX mode if it has one.'
            )
        }
        @{
            Match     = @('EasyAntiCheat*', 'EAAntiCheat*', 'BEClient*', 'BEService*', 'BEDaisy*', 'vgk*', 'vgc*', 'FACEIT*', 'mhyprot*', 'xhunter*')
            Component = 'anti-cheat'
            Category  = 'AntiCheat'
            Explain   = 'The crash happened inside the game''s anti-cheat software.'
            Fixes     = @(
                'Repair the anti-cheat: most games have an EasyAntiCheat or BattlEye folder with a setup file that has a Repair option.'
                'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
                'Close tools that hook into games (trainers, macro tools, some RGB and monitoring apps) and try again.'
                'Install the latest Windows updates.'
            )
        }
        @{
            Match     = @('DiscordHook*', 'discord_hook*')
            Component = 'Discord overlay'
            Category  = 'Overlay'
            Explain   = 'The Discord in-game overlay loads itself into the game, and the crash happened inside it.'
            Fixes     = @('Turn off the Discord in-game overlay (Discord Settings > Game Overlay).')
        }
        @{
            Match     = @('gameoverlayrenderer*')
            Component = 'Steam overlay'
            Category  = 'Overlay'
            Explain   = 'The Steam overlay loads itself into the game, and the crash happened inside it.'
            Fixes     = @('Turn off the Steam overlay for this game (right-click the game > Properties > General).')
        }
        @{
            Match     = @('RTSSHooks*', 'RTSS*')
            Component = 'RivaTuner / MSI Afterburner overlay'
            Category  = 'Overlay'
            Explain   = 'RivaTuner Statistics Server (installed with MSI Afterburner) loads itself into the game to show the FPS counter, and the crash happened inside it.'
            Fixes     = @('Close RivaTuner Statistics Server, or add this game in RivaTuner with "Application detection level" set to None.')
        }
        @{
            Match     = @('nvspcap*', 'nvppe*', 'NvCamera*')
            Component = 'NVIDIA app / GeForce Experience overlay'
            Category  = 'Overlay'
            Explain   = 'The NVIDIA overlay (recording, filters, performance panel) loads itself into the game, and the crash happened inside it.'
            Fixes     = @('Turn off the in-game overlay in the NVIDIA app (or GeForce Experience).')
        }
        @{
            Match     = @('OWClient*', 'Overwolf*', 'ow-graphics*')
            Component = 'Overwolf overlay'
            Category  = 'Overlay'
            Explain   = 'Overwolf loads itself into the game, and the crash happened inside it.'
            Fixes     = @('Close Overwolf, or turn off its overlay for this game.')
        }
        @{
            Match     = @('EOSOVH*')
            Component = 'Epic Games overlay'
            Category  = 'Overlay'
            Explain   = 'The Epic Games overlay loads itself into the game, and the crash happened inside it.'
            Fixes     = @('Update the Epic Games Launcher, then verify the game files.')
        }
        @{
            Match     = @('graphics-hook*', 'obs-vulkan*', 'obs-opengl*')
            Component = 'OBS game capture'
            Category  = 'Overlay'
            Explain   = 'OBS''s Game Capture loads itself into the game to record it, and the crash happened inside it.'
            Fixes     = @('Close OBS, or switch its source from Game Capture to Display Capture or Window Capture.')
        }
        @{
            Match     = @('Nahimic*', 'NahimicOSD*', 'A-Volute*', 'AudioDevProps*')
            Component = 'Nahimic / Sonic Studio audio software'
            Category  = 'Overlay'
            Explain   = 'Nahimic audio software (preinstalled on many MSI, Dell, Alienware and ASUS PCs) loads itself into every game and is a well-known cause of game crashes.'
            Fixes     = @('Uninstall the Nahimic app and disable the "Nahimic service" in Services. MSI and other makers may reinstall it with driver updates, so check again later.')
        }
        @{
            Match     = @('ReShade*', 'dxgi_reshade*')
            Component = 'ReShade'
            Category  = 'Mod'
            Explain   = 'ReShade adds graphics filters to the game, and the crash happened inside it.'
            Fixes     = @('Remove ReShade from the game folder, or update it to the latest version.')
        }
        @{
            Match     = @('ntdll.dll', 'KERNELBASE.dll', 'kernel32.dll', 'combase.dll', 'user32.dll', 'win32u.dll')
            Component = 'core Windows file'
            Category  = 'Windows'
            Explain   = 'This is a core Windows file every program uses. It is where the crash was noticed, not usually its cause - the program itself, a mod or an overlay is more likely.'
            Fixes     = @(
                'Update the game or app to its latest version.'
                'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
                'Turn off overlays (Discord, Steam, NVIDIA app, MSI Afterburner/RTSS) and try again.'
            )
        }
        @{
            Match     = @('ucrtbase.dll', 'msvcp1*', 'vcruntime1*', 'msvcr1*')
            Component = 'Microsoft Visual C++ runtime'
            Category  = 'Runtime'
            Explain   = 'Programs use the Visual C++ runtime for basic tasks. The bug is usually in the program, but a damaged runtime can cause it too.'
            Fixes     = @(
                'Reinstall the latest Microsoft Visual C++ Redistributable (both x64 and x86).'
                'Update the game or app to its latest version.'
            )
        }
        @{
            Match     = @('clr.dll', 'coreclr.dll', 'mscorwks.dll')
            Component = '.NET runtime'
            Category  = 'Runtime'
            Explain   = 'The crash happened in .NET, which the program is built on. The bug is usually in the program itself.'
            Fixes     = @(
                'Update the game or app to its latest version.'
                'Install the latest Windows updates.'
            )
        }
        @{
            Match     = @('UnityPlayer.dll', 'GameAssembly.dll', 'mono-2.0-*')
            Component = 'Unity game engine (part of the game)'
            Category  = 'Engine'
            Explain   = 'The crash happened inside the game''s own engine files.'
            Fixes     = @(
                'Update the game or app to its latest version.'
                'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
                'Remove mods, then add them back one at a time to find the one causing it.'
            )
        }
        @{
            Match     = @('steam_api*', 'steamclient*', 'tier0_s*', 'vstdlib_s*')
            Component = 'Steam'
            Category  = 'Launcher'
            Explain   = 'The crash happened inside Steam''s files that the game uses.'
            Fixes     = @(
                'Restart Steam and make sure it is up to date.'
                'Verify or repair the game files (Steam: right-click the game > Properties > Installed Files > Verify integrity of game files).'
            )
        }
        @{
            Match     = @('libcef.dll', 'CefSharp*', 'chrome_elf.dll')
            Component = 'built-in web browser (used by launchers and many apps)'
            Category  = 'Launcher'
            Explain   = 'Many launchers and apps show their screens with a built-in web browser, and the crash happened inside it.'
            Fixes     = @(
                'Update the game or app to its latest version.'
                'Turn off "hardware acceleration" in the app''s settings, if it has that option.'
            )
        }
        @{
            Match     = @('XAudio2_*', 'AudioSes.dll')
            Component = 'Windows audio'
            Category  = 'Audio'
            Explain   = 'The crash happened in Windows'' audio system while the program was playing sound.'
            Fixes     = @(
                'Update your audio driver (Realtek, or your headset''s software).'
                'Switch to a different playback device, or reconnect your headset.'
                'For older games, install the "DirectX End-User Runtime (June 2010)" from Microsoft.'
            )
        }
    )
}
