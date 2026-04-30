@echo off
REM obsidian-wiki Skills 安装脚本
REM 将 skills 安装到当前项目的 .claude/skills/ 目录
REM
REM 使用方法:
REM   cd your-project && path\to\obsidian-wiki\TEMPLATE\scripts\install.bat

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "TEMPLATE_DIR=%SCRIPT_DIR%.."
set "SKILL_ROOT=%SCRIPT_DIR%..\.."
set "PROJECT_DIR=%cd%"

REM 验证目标目录
if "%PROJECT_DIR%"=="" (
    echo [错误] PROJECT_DIR 未设置
    exit /b 1
)

if not exist "%PROJECT_DIR%" (
    echo [错误] 目标目录不存在: %PROJECT_DIR%
    exit /b 1
)

REM 验证 skill 源
if not exist "%SKILL_ROOT%\SKILL.md" (
    echo [错误] 找不到 SKILL.md，请确认脚本路径正确
    exit /b 1
)

echo ========================================
echo  obsidian-wiki Skills 安装程序
echo ========================================
echo.
echo  目标目录: %PROJECT_DIR%\.claude\skills\
echo.

REM 检查目标目录是否存在
if not exist "%PROJECT_DIR%\.claude" (
    echo [创建] .claude 目录...
    mkdir "%PROJECT_DIR%\.claude"
)

if not exist "%PROJECT_DIR%\.claude\skills" (
    echo [创建] skills 目录...
    mkdir "%PROJECT_DIR%\.claude\skills"
)

echo [安装] obsidian-wiki skill...
if not exist "%PROJECT_DIR%\.claude\skills\obsidian-wiki" mkdir "%PROJECT_DIR%\.claude\skills\obsidian-wiki"
call :install_skill "%SKILL_ROOT%\SKILL.md" "%PROJECT_DIR%\.claude\skills\obsidian-wiki\SKILL.md"

echo [安装] docs-ingest skill...
if not exist "%PROJECT_DIR%\.claude\skills\docs-ingest" mkdir "%PROJECT_DIR%\.claude\skills\docs-ingest"
call :install_skill "%SKILL_ROOT%\docs-ingest\SKILL.md" "%PROJECT_DIR%\.claude\skills\docs-ingest\SKILL.md"

echo [安装] wiki-query skill...
if not exist "%PROJECT_DIR%\.claude\skills\wiki-query" mkdir "%PROJECT_DIR%\.claude\skills\wiki-query"
call :install_skill "%SKILL_ROOT%\wiki-query\SKILL.md" "%PROJECT_DIR%\.claude\skills\wiki-query\SKILL.md"

echo [安装] wiki-lint skill...
if not exist "%PROJECT_DIR%\.claude\skills\wiki-lint" mkdir "%PROJECT_DIR%\.claude\skills\wiki-lint"
call :install_skill "%SKILL_ROOT%\wiki-lint\SKILL.md" "%PROJECT_DIR%\.claude\skills\wiki-lint\SKILL.md"

echo [安装] wiki-capture skill...
if not exist "%PROJECT_DIR%\.claude\skills\wiki-capture" mkdir "%PROJECT_DIR%\.claude\skills\wiki-capture"
call :install_skill "%SKILL_ROOT%\wiki-capture\SKILL.md" "%PROJECT_DIR%\.claude\skills\wiki-capture\SKILL.md"

echo [安装] learning-tracker skill...
if not exist "%PROJECT_DIR%\.claude\skills\learning-tracker" mkdir "%PROJECT_DIR%\.claude\skills\learning-tracker"
call :install_skill "%SKILL_ROOT%\learning-tracker\learning-tracker.sh" "%PROJECT_DIR%\.claude\skills\learning-tracker\learning-tracker.sh"
call :install_skill "%SKILL_ROOT%\learning-tracker\analyzer.sh" "%PROJECT_DIR%\.claude\skills\learning-tracker\analyzer.sh"

echo [安装] wiki-lint.sh...
if not exist "%PROJECT_DIR%\scripts" mkdir "%PROJECT_DIR%\scripts"
copy /Y "%SKILL_ROOT%\wiki-lint\wiki-lint.sh" "%PROJECT_DIR%\scripts\wiki-lint.sh" >nul 2>&1
echo   OK wiki-lint.sh

echo.
echo ========================================
echo  安装完成!
echo ========================================
echo.
echo  已安装的 skills:
echo    - obsidian-wiki
echo    - docs-ingest
echo    - wiki-query
echo    - wiki-lint
echo    - wiki-capture
echo    - learning-tracker
echo.
echo  已安装的工具:
echo    - scripts\wiki-lint.sh
echo.
echo  使用方法:
echo    1. 重启 Claude Code
echo    2. 在新项目中说 "使用 obsidian-wiki"
echo.

pause
goto :eof

REM === 子例程：安装单个 skill 文件 ===
:install_skill
setlocal enabledelayedexpansion
set "SRC=%~1"
set "DEST=%~2"
REM 确保目标目录存在
for %%D in ("%DEST%") do set "DEST_DIR=%%~dpD"
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
copy /Y "%SRC%" "%DEST%" >nul 2>&1
if errorlevel 1 (
    echo   X 安装失败: %SRC%
    endlocal
    exit /b 1
)
for %%F in ("%SRC%") do echo   OK %%~nxF
endlocal
exit /b 0
