@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -NoLogo -STA -ExecutionPolicy Bypass -File "%~dp0MojibakeFixer.ps1"
if errorlevel 1 (
    echo.
    echo The program could not start. Please check the error above.
    pause
)
