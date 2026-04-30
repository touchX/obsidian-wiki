#!/usr/bin/env bash
#
# Skill 路由器
#
# 功能：根据文件 MIME 类型，路由到对应的处理 skill
# 用途：docs-ingest 的多格式文档处理调度
#

set -euo pipefail

# MIME 类型到 Skill 的映射表
# 格式: ["MIME类型"]="Skill名称"
declare -A MIME_TO_SKILL=(
    # PDF 系列
    ["application/pdf"]="pdf"

    # Microsoft Office (OpenXML)
    ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"]="docx"
    ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]="xlsx"
    ["application/vnd.openxmlformats-officedocument.presentationml.presentation"]="pptx"

    # 传统 Office (已转换为现代格式)
    ["application/msword"]="docx"
    ["application/vnd.ms-excel"]="xlsx"
    ["application/vnd.ms-powerpoint"]="pptx"

    # Markdown 系列
    ["text/markdown"]="internal"
    ["text/x-markdown"]="internal"

    # 网页 (现有 defuddle)
    ["text/html"]="defuddle"
    ["application/xhtml+xml"]="defuddle"

    # 纯文本
    ["text/plain"]="internal"

    # JSON/XML
    ["application/json"]="internal"
    ["text/xml"]="internal"
    ["application/xml"]="internal"
)

# 获取 MIME 类型对应的 Skill
# 参数:
#   $1 - MIME 类型字符串
# 输出:
#   Skill 名称 (unknown 表示未知类型)
get_skill_for_mime() {
    local mime_type="$1"
    local skill="${MIME_TO_SKILL[$mime_type]:-unknown}"
    echo "$skill"
}

# 检查 Skill 是否可用
# 参数:
#   $1 - Skill 名称
# 返回值:
#   0 - 可用
#   1 - 不可用
check_skill_available() {
    local skill="$1"

    # internal 和 defuddle 默认可用
    if [[ "$skill" == "internal" ]] || [[ "$skill" == "defuddle" ]]; then
        return 0
    fi

    # 其他 skill 检查 SKILL.md 是否存在
    # 计算项目根目录: scripts/ -> docs-ingest/ -> 项目根/
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/../.." && pwd)"

    # 路径: project_root/TEMPLATE/.claude/skills/${skill}/SKILL.md
    local skill_path="$project_root/TEMPLATE/.claude/skills/${skill}/SKILL.md"
    if [[ -f "$skill_path" ]]; then
        return 0
    fi
    # 降级路径: docs-ingest/${skill}/SKILL.md (向后兼容)
    skill_path="$script_dir/../${skill}/SKILL.md"
    if [[ -f "$skill_path" ]]; then
        return 0
    fi
    return 1
}

# 路由文件到对应的 Skill
# 参数:
#   $1 - 文件路径
# 输出:
#   JSON 格式: {"mime":"...","skill":"...","available":true/false}
route_file() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo '{"error":"file not found"}'
        return 1
    fi

    # 检查文件命令是否存在，不存在时降级
    if ! command -v file &> /dev/null; then
        echo '{"error":"file command not found"}'
        return 1
    fi

    # 获取 MIME 类型
    local mime_type
    mime_type=$(file --mime-type -b "$file_path" 2>/dev/null)

    # 对于空文件、text/plain 或检测失败的情况，使用扩展名降级
    if [ -z "$mime_type" ] || [[ "$mime_type" == "text/plain" ]] || [[ "$mime_type" == "inode/x-empty" ]]; then
        local ext="${file_path##*.}"
        case "$ext" in
            docx) mime_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document" ;;
            xlsx) mime_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ;;
            pdf)  mime_type="application/pdf" ;;
            md)   mime_type="text/markdown" ;;
            doc)  mime_type="application/msword" ;;
            xls)  mime_type="application/vnd.ms-excel" ;;
            ppt)  mime_type="application/vnd.ms-powerpoint" ;;
            pptx) mime_type="application/vnd.openxmlformats-officedocument.presentationml.presentation" ;;
            html) mime_type="text/html" ;;
            htm)  mime_type="text/html" ;;
            txt)  mime_type="text/plain" ;;
            *)    mime_type="unknown/$ext" ;;
        esac
    fi

    # 获取对应的 Skill
    local skill
    skill=$(get_skill_for_mime "$mime_type")

    # 检查 Skill 可用性
    local available
    if check_skill_available "$skill"; then
        available="true"
    else
        available="false"
    fi

    # 输出 JSON 格式结果
    echo "{\"mime\":\"$mime_type\",\"skill\":\"$skill\",\"available\":$available}"
}

# 测试函数
test_router() {
    echo "=== Skill 路由器测试 ==="
    echo

    # 测试 MIME 类型映射
    echo "测试 1: MIME 类型映射"
    local test_mimes=(
        "application/pdf"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "text/markdown"
        "text/html"
        "text/plain"
        "application/json"
        "unknown/type"
    )

    for mime in "${test_mimes[@]}"; do
        local skill
        skill=$(get_skill_for_mime "$mime")
        echo "  $mime → $skill"
    done
    echo

    # 测试 Skill 可用性检查
    echo "测试 2: Skill 可用性检查"
    local test_skills=("internal" "defuddle" "pdf" "docx" "unknown")

    for skill in "${test_skills[@]}"; do
        if check_skill_available "$skill"; then
            echo "  $skill: 可用"
        else
            echo "  $skill: 不可用"
        fi
    done
    echo

    echo "=== 测试完成 ==="
}

# 主函数
main() {
    if [[ "${1:-}" == "--test" ]]; then
        test_router
    elif [[ "${1:-}" == "--route" ]] && [[ -n "${2:-}" ]]; then
        route_file "$2"
    else
        echo "用法: $0 [--test|--route <file>]"
        echo
        echo "选项:"
        echo "  --test            运行测试"
        echo "  --route <file>    路由文件到对应 Skill"
        exit 1
    fi
}

# 如果直接运行脚本，执行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
