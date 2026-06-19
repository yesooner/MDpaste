@echo off
setlocal EnableDelayedExpansion
set "MDPASTE_HOME=%~dp0"
set "MDPASTE_HOME=%MDPASTE_HOME:~0,-1%"
cd /d "%MDPASTE_HOME%"

set "APPDATA=%MDPASTE_HOME%\portable-data\Roaming"
set "LOCALAPPDATA=%MDPASTE_HOME%\portable-data\Local"
set "PATH=%MDPASTE_HOME%;%MDPASTE_HOME%\_internal;%MDPASTE_HOME%\_internal\pandoc;%PATH%"
set "NATIVE_LAUNCHER=%MDPASTE_HOME%\MdPaste-portable-launcher.exe"

if exist "%NATIVE_LAUNCHER%" (
  rem Native launcher exits when MdPaste is already running.
  "%NATIVE_LAUNCHER%"
  if errorlevel 1 exit /b %ERRORLEVEL%
  exit /b 0
)

if not exist "%APPDATA%\PasteMD" mkdir "%APPDATA%\PasteMD"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%MDPASTE_HOME%\cache" mkdir "%MDPASTE_HOME%\cache"
set "CONFIG_PATH=%APPDATA%\PasteMD\config.json"
set "MARKER_PATH=%APPDATA%\PasteMD\.portable-home"

if not exist "%MDPASTE_HOME%\MdPaste.exe" (
  echo [ERROR] MdPaste.exe was not found.
  echo Please keep MDPASTE.cmd, MdPaste.exe, and _internal in the same folder.
  pause
  exit /b 1
)

if not exist "%MDPASTE_HOME%\_internal\pandoc\pandoc.exe" (
  echo [ERROR] Bundled Pandoc was not found.
  echo Please download the complete portable ZIP from GitHub Releases.
  pause
  exit /b 1
)

set "NEEDS_CONFIG=0"
if not exist "%CONFIG_PATH%" set "NEEDS_CONFIG=1"
if not exist "%MARKER_PATH%" set "NEEDS_CONFIG=1"
if exist "%MARKER_PATH%" (
  set "CONFIG_HOME="
  set /p CONFIG_HOME=<"%MARKER_PATH%"
  if /I not "!CONFIG_HOME!"=="%MDPASTE_HOME%" set "NEEDS_CONFIG=1"
)

if "%NEEDS_CONFIG%"=="0" goto launch_app

:configure_if_needed
if "%NEEDS_CONFIG%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%MDPASTE_HOME%\portable-config.ps1" -HomeDir "%MDPASTE_HOME%"
  if errorlevel 1 (
    echo [ERROR] MdPaste portable config failed.
    pause
    exit /b 1
  )
)

:launch_app
start "" "%MDPASTE_HOME%\MdPaste.exe"
exit
