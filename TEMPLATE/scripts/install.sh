#!/bin/bash
# obsidian-wiki Skills 安装脚本
# 将 skills 安装到当前项目的 .claude/skills/ 目录

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"

echo "========================================"
echo "  obsidian-wiki Skills 安装程序"
echo "========================================"
echo ""
echo "  目标目录: $PROJECT_DIR/.claude/skills/"
echo ""

# 检查目标目录是否存在
mkdir -p "$PROJECT_DIR/.claude/skills"

# 安装 skills
echo "[安装] obsidian-wiki skill..."
cp "$TEMPLATE_DIR/SKILL.md" "$PROJECT_DIR/.claude/skills/obsidian-wiki.md"

echo "[安装] docs-ingest skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/docs-ingest"
cp "$TEMPLATE_DIR/docs-ingest/SKILL.md" "$PROJECT_DIR/.claude/skills/docs-ingest/SKILL.md"

echo "[安装] wiki-query skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/wiki-query"
cp "$TEMPLATE_DIR/wiki-query/SKILL.md" "$PROJECT_DIR/.claude/skills/wiki-query/SKILL.md"

echo "[安装] wiki-lint skill..."
mkdir -p "$PROJECT_DIR/.claude/skills/wiki-lint"
cp "$TEMPLATE_DIR/wiki-lint/SKILL.md" "$PROJECT_DIR/.claude/skills/wiki-lint/SKILL.md"

echo ""
echo "========================================"
echo "  安装完成!"
echo "========================================"
echo ""
echo "  已安装的 skills:"
echo "    - obsidian-wiki"
echo "    - docs-ingest"
echo "    - wiki-query"
echo "    - wiki-lint"
echo ""
echo "  使用方法:"
echo "    1. 重启 Claude Code"
echo "    2. 在新项目中说 '使用 obsidian-wiki'"
echo "    3. 运行 ./install.sh 初始化 skills"
echo ""
