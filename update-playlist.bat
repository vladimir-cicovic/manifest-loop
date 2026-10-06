@echo off
rem Offline mode helper for Windows: rebuilds playlist.js after you add or remove images or music.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\generate-playlist.ps1"
pause
