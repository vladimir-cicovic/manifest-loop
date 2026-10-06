@echo off
rem Online mode for Windows: refreshes the playlist and serves manifest-loop on your local network
rem with Python's built-in http.server. Close this window to stop the server.
chcp 65001 >nul
cd /d "%~dp0"
title manifest-loop server
if "%PORT%"=="" set PORT=8765

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\generate-playlist.ps1"

set PY=
where py >nul 2>nul && set PY=py -3
if not defined PY (python -c "import sys" >nul 2>nul && set PY=python)
if not defined PY (python3 -c "import sys" >nul 2>nul && set PY=python3)
if not defined PY (
  echo.
  echo  Python 3 was not found. Install it from https://www.python.org/downloads/
  echo  and tick "Add python.exe to PATH" during setup, then run start.bat again.
  echo  You can still use offline mode: just open index.html.
  pause
  exit /b 1
)

echo.
echo  ====================================================
echo   manifest-loop is running:
echo.
echo     This computer:   http://localhost:%PORT%
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'vEthernet|VMware|VirtualBox|Loopback|WSL' -and $_.IPAddress -notlike '169.254*' -and $_.IPAddress -notlike '127.*' }).IPAddress"`) do echo     Phone / TV:      http://%%i:%PORT%
echo.
echo   Your phone must be on the same Wi-Fi network.
echo   If Windows asks about the firewall, allow access on private networks.
echo   Close this window to stop the server.
echo  ====================================================
echo.

start "" http://localhost:%PORT%
%PY% -m http.server %PORT% --bind 0.0.0.0
pause
