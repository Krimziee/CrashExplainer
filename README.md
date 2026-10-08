# Crash Explainer

Explains your PC's recent crashes in plain words and tells you what to try,
easiest fixes first. Covers blue screens, program and game crashes, freezes,
sudden shutdowns, graphics driver resets and hardware errors.

**It makes no changes to your PC.** It only reads the crash records Windows
already keeps, and it doesn't need admin rights. It writes no files, no logs
and no settings, and doesn't touch the registry, drivers or services. The only
things that leave it are on your click: the clipboard (Copy) and your browser
(Search online).

## How to use

Double-click **`Explain Crashes.cmd`**. A window opens with your crashes on
the left and, for the selected one, what happened and what to try on the
right. Choose how far back to look (7 to 90 days), and sort by **Most serious**
or **Most recent**.

Severity:

- **Serious**: blue screens, sudden power loss, fatal hardware errors
- **Medium**: program crashes, graphics driver resets, power button shutdowns
- **Minor**: program freezes, corrected hardware errors

For a text report instead of the window:

```powershell
powershell -ExecutionPolicy Bypass -File CrashExplainer.ps1 -Console -Days 30
```

| Option              | What it does                                           |
|---------------------|--------------------------------------------------------|
| `-Days 30`          | How far back to look (default 14, up to 90)            |
| `-SortBy Recent`    | Most recent first (default: `Severity`, most serious)  |
| `-Console`          | Text report in the console instead of the window       |
| `-All`              | Console: show every crash, not just 20                 |
| `-NoPause`          | Console: don't wait for Enter at the end               |

## What it reads

| Windows log | Event                                  | Shown as                          |
|-------------|----------------------------------------|-----------------------------------|
| System      | WER-SystemErrorReporting 1001          | Blue screen                       |
| System      | Kernel-Power 41                        | Sudden shutdown / power button    |
| System      | Display 4101                           | Graphics driver reset             |
| System      | WHEA-Logger                            | Hardware error                    |
| Application | Application Error 1000                 | Program crash                     |
| Application | Application Hang 1002                  | Program freeze                    |

Repeats of the same crash are grouped together. "The big picture" points out
one cause behind many crashes, for example the same graphics driver showing
up in several games.

## Adding to the rules

All explanations live in `rules\`, separate from the code:

- `BugChecks.psd1`: blue screen codes
- `Exceptions.psd1`: program crash codes
- `Modules.psd1`: files a crash can happen in (drivers, overlays, anti-cheat...)
- `General.psd1`: everything else, plus the big picture notes

Write fixes easiest first. When a fix also appears in another rule, copy its
wording exactly, so the report shows it only once.

Crash Explainer only displays and explains what the event logs say. It does
not read crash dump files.
