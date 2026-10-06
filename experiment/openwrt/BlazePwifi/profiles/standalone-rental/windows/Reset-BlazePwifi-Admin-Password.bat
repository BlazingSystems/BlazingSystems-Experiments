@echo off
setlocal
cd /d "%~dp0"
title BlazePwifi Admin Password Reset

echo.
echo BlazePwifi Admin Password Reset
echo ===============================
echo.
echo This resets BlazePwifi admin credentials to:
echo   Username: admin
echo   Password: admin
echo.
echo Works with Standalone Rental and full BlazePwifi.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Reset-BlazePwifi-Admin-Password.ps1"
set RC=%ERRORLEVEL%

echo.
if not "%RC%"=="0" (
  echo Reset failed with code %RC%.
) else (
  echo Reset completed successfully.
)
echo.
pause
exit /b %RC%
