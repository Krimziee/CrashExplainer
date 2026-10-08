@echo off
rem Opens Crash Explainer. It only reads Windows' crash logs - no admin rights, no changes.
rem For a text report instead of the window, run: CrashExplainer.ps1 -Console
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0CrashExplainer.ps1"
