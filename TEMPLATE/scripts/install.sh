#!/bin/bash
# obsidian-wiki Skills 安装脚本
# 将 skills 安装到当前项目的 .claude/skills/ 目录
#
# 使用方法:
#   cd your-project && /path/to/obsidian-wiki/TEMPLATE/scripts/install.sh

set -e  # 遇到错误立即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_ROOT="$(dirname "$TEMPLATE_DIR")"
PROJECT_DIR="$(pwd)"

echo "========================================="
echo "  obsidian-wiki Skills 安装程序"
echo "========================================="
echo ""
echo "  Skill 源: $SKILL_ROOT"
echo "  目标目录: $PROJECT_DIR/.claude/skills/"
echo ""

# 检查 skill 源目录
if [ ! -f "$SKILL_ROOT/SKILL.md" ]; then
    echo "[错误] 找不到 SKILL.md，请确认脚本路径正确"
    exit 1
fi

# 检查目标目录是否存在
if [ ! -d "$PROJECT_DIR/.claude" ]; then
    echo "[创建] .claude 目录..."
    mkdir -p "$PROJECT_DIR/.claude"
fi

if [ ! -d "$PROJECT_DIR/.claude/skills" ]; then
    echo "[创建] skills 目录..."
    mkdir -p "$PROJECT_DIR/.claude/skills"
fi

# 安装 skills 函数
install_skill() {
    local src="$1"
    local dest="$2"
    local dir
    dir="$(dirname "$dest")"
    [ -d "$dir" ] || mkdir -p "$dir"
    if cp "$src" "$dest" 2>/dev/null; then
        echo "  ✓ $(basename "$dir")/$(basename "$src")"
    else
        echo "  ✗ 安装失败: $src"
        exit 1
    fi
}

echo "[安装] obsidian-wiki skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/obsidian-wiki"
install_skill "$SKILL_ROOT/SKILL.md" "$PROJECT_DIR/.claude/skills/obsidian-wiki/SKILL.md"

echo "[安装] docs-ingest skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/docs-ingest"
install_skill "$SKILL_ROOT/docs-ingest/SKILL.md" "$PROJECT_DIR/.claude/skills/docs-ingest/SKILL.md"

echo "[安装] wiki-query skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/wiki-query"
install_skill "$SKILL_ROOT/wiki-query/SKILL.md" "$PROJECT_DIR/.claude/skills/wiki-query/SKILL.md"

echo "[安装] wiki-lint skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/wiki-lint"
install_skill "$SKILL_ROOT/wiki-lint/SKILL.md" "$PROJECT_DIR/.claude/skills/wiki-lint/SKILL.md"
install_skill "$SKILL_ROOT/wiki-lint/lint.sh" "$PROJECT_DIR/.claude/skills/wiki-lint/lint.sh"
chmod +x "$PROJECT_DIR/.claude/skills/wiki-lint/lint.sh"

echo "[安装] wiki-capture skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/wiki-capture"
install_skill "$SKILL_ROOT/wiki-capture/SKILL.md" "$PROJECT_DIR/.claude/skills/wiki-capture/SKILL.md"

echo "[安装] learning-tracker skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/learning-tracker"
install_skill "$SKILL_ROOT/learning-tracker/SKILL.md" "$PROJECT_DIR/.claude/skills/learning-tracker/SKILL.md"
install_skill "$SKILL_ROOT/learning-tracker/tracker.sh" "$PROJECT_DIR/.claude/skills/learning-tracker/tracker.sh"
chmod +x "$PROJECT_DIR/.claude/skills/learning-tracker/tracker.sh"
install_skill "$SKILL_ROOT/learning-tracker/analyzer.sh" "$PROJECT_DIR/.claude/skills/learning-tracker/analyzer.sh"
chmod +x "$PROJECT_DIR/.claude/skills/learning-tracker/analyzer.sh"

echo ""
echo "========================================="
echo "  安装完成!"
echo "========================================="
echo ""
echo "  已安装的 skills:"
echo "    - obsidian-wiki"
echo "    - docs-ingest"
echo "    - wiki-query"
echo "    - wiki-lint"
echo "    - wiki-capture"
echo "    - learning-tracker"
echo ""
echo "  使用方法:"
echo "    1. 重启 Claude Code"
echo "    2. 在新项目中说 '使用 obsidian-wiki'"
echo ""
