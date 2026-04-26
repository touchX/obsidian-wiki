@echo off
REM obsidian-wiki Skills 安装脚本
REM 将 skills 安装到当前项目的 .claude/skills/ 目录

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "TEMPLATE_DIR=%SCRIPT_DIR%.."
set "PROJECT_DIR=%cd%"

REM 切换到模板目录
cd /d "%TEMPLATE_DIR%"

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

REM 安装 skills
echo [安装] obsidian-wiki skill...
copy "SKILL.md" "%PROJECT_DIR%\.claude\skills\obsidian-wiki.md" /Y

echo [安装] docs-ingest skill...
if not exist "%PROJECT_DIR%\.claude\skills\docs-ingest" mkdir "%PROJECT_DIR%\.claude\skills\docs-ingest"
copy "docs-ingest\SKILL.md" "%PROJECT_DIR%\.claude\skills\docs-ingest\SKILL.md" /Y

echo [安装] wiki-query skill...
if not exist "%PROJECT_DIR%\.claude\skills\wiki-query" mkdir "%PROJECT_DIR%\.claude\skills\wiki-query"
copy "wiki-query\SKILL.md" "%PROJECT_DIR%\.claude\skills\wiki-query\SKILL.md" /Y

echo [安装] wiki-lint skill...
if not exist "%PROJECT_DIR%\.claude\skills\wiki-lint" mkdir "%PROJECT_DIR%\.claude\skills\wiki-lint"
copy "wiki-lint\SKILL.md" "%PROJECT_DIR%\.claude\skills\wiki-lint\SKILL.md" /Y

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
echo.
echo  使用方法:
echo    1. 重启 Claude Code
echo    2. 在新项目中说 "使用 obsidian-wiki"
echo    3. 运行 install.bat 初始化 skills
echo.

pause