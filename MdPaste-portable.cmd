@echo off
setlocal EnableDelayedExpansion
set "MDPASTE_HOME=%~dp0"
set "MDPASTE_HOME=%MDPASTE_HOME:~0,-1%"
cd /d "%MDPASTE_HOME%"

set "APPDATA=%MDPASTE_HOME%\portable-data\Roaming"
set "LOCALAPPDATA=%MDPASTE_HOME%\portable-data\Local"
set "PATH=%MDPASTE_HOME%;%MDPASTE_HOME%\_internal;%MDPASTE_HOME%\_internal\pandoc;%PATH%"

if not exist "%APPDATA%\PasteMD" mkdir "%APPDATA%\PasteMD"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%MDPASTE_HOME%\cache" mkdir "%MDPASTE_HOME%\cache"

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

powershell -NoProfile -ExecutionPolicy Bypass -File "%MDPASTE_HOME%\portable-config.ps1" -HomeDir "%MDPASTE_HOME%"
if errorlevel 1 (
  echo [ERROR] MdPaste portable config failed.
  pause
  exit /b 1
)

start "" "%MDPASTE_HOME%\MdPaste.exe"
exit
