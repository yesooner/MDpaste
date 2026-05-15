@echo off
setlocal EnableDelayedExpansion

set "MDPASTE_HOME=%~dp0"
set "MDPASTE_HOME=%MDPASTE_HOME:~0,-1%"

echo ============================================
echo   PasteMD 便携版 - 开机自启管理
echo ============================================
echo.
echo 当前文件夹: %MDPASTE_HOME%
echo.

:: 检查任务是否存在
schtasks /query /tn "PasteMD-Portable" 2>nul >nul
set TaskExists=!errorlevel!

if !TaskExists!==0 (
    echo [状态] 已启用开机自启
) else (
    echo [状态] 未启用开机自启
)
echo.
echo 请选择操作:
echo   1. 启用开机自启
echo   2. 禁用开机自启
echo   3. 退出
echo.

set /p choice=请输入选项 (1/2/3): 

if "!choice!"=="1" goto enable
if "!choice!"=="2" goto disable
if "!choice!"=="3" goto end

echo [错误] 无效选项
goto end

:enable
echo.
if !TaskExists!==0 (
    echo 更新开机自启任务（路径已变化）...
    schtasks /delete /tn "PasteMD-Portable" /f 2>nul
) else (
    echo 启用开机自启...
)
schtasks /create /tn "PasteMD-Portable" /tr "\"%MDPASTE_HOME%\MdPaste-portable.cmd\"" /sc onlogon /rl limited /f 2>nul
if errorlevel 1 (
    echo [失败] 请以管理员身份运行此脚本
    pause
    goto end
)

echo [成功] 已设置开机自启
echo        将在登录时自动启动 PasteMD
pause
goto end

:disable
echo.
echo 正在禁用开机自启...

schtasks /delete /tn "PasteMD-Portable" /f 2>nul

echo [成功] 已禁用开机自启
pause
goto end

:end
exit /b