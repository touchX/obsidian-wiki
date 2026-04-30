#!/usr/bin/env bash
# preconvert.sh - 旧格式文件预转换层
#
# 功能：将旧版 Microsoft Office 格式转换为现代格式
# 支持：.doc → .docx, .xls → .xlsx, .ppt → .pptx
# 降级：LibreOffice 不可用时返回原文件路径
#
# 依赖：LibreOffice (soffice 命令)
# 作者：obsidian-wiki project
# 版本：0.2.0

set -euo pipefail

# ==================== 颜色和日志函数 ====================

# ANSI 颜色代码
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'

# 日志函数
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&2
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

# ==================== 依赖检查函数 ====================

# check_libreoffice - 检查 LibreOffice 是否可用
# 返回值：0 - 可用, 1 - 不可用
check_libreoffice() {
    if command -v soffice &>/dev/null; then
        log_info "LibreOffice 已安装: $(soffice --version 2>&1 | head -n1)"
        return 0
    fi

    log_warn "LibreOffice 未找到，尝试检查 Python UNO 库..."

    if python3 -c "import uno" 2>/dev/null; then
        log_info "Python UNO 库可用"
        return 0
    fi

    log_warn "LibreOffice 不可用，将跳过格式转换"
    return 1
}

# ==================== MIME 类型映射 ====================

# get_target_format - 根据 MIME 类型获取目标格式
# 参数：$1 - MIME 类型
# 输出：目标格式扩展名（如 docx）或空字符串
get_target_format() {
    local mime_type="$1"

    case "$mime_type" in
        application/msword)
            echo "docx"
            ;;
        application/vnd.ms-excel)
            echo "xlsx"
            ;;
        application/vnd.ms-powerpoint)
            echo "pptx"
            ;;
        *)
            echo ""
            ;;
    esac
}

# ==================== 转换函数 ====================

# preconvert_legacy_format - 预转换旧格式文件
# 参数：
#   $1 - 文件路径（绝对或相对）
#   $2 - MIME 类型
# 输出：转换后的文件路径（原文件路径如果转换失败或跳过）
# 返回值：0 - 成功或跳过, 1 - 转换失败
preconvert_legacy_format() {
    local input_file="$1"
    local mime_type="$2"

    # 验证文件存在
    if [[ ! -f "$input_file" ]]; then
        log_error "文件不存在: $input_file"
        echo "$input_file"
        return 1
    fi

    # 获取目标格式
    local target_format
    target_format=$(get_target_format "$mime_type")

    if [[ -z "$target_format" ]]; then
        log_info "无需转换的格式: $mime_type"
        echo "$input_file"
        return 0
    fi

    log_info "检测到旧格式 $mime_type，目标格式: $target_format"

    # 检查 LibreOffice 可用性
    if ! check_libreoffice; then
        log_warn "LibreOffice 不可用，跳过转换: $input_file"
        echo "$input_file"
        return 0
    fi

    # 准备转换
    local file_dir
    local file_name
    local file_base
    local output_file

    file_dir=$(dirname "$input_file")
    file_name=$(basename "$input_file")
    file_base="${file_name%.*}"
    output_file="${file_dir}/${file_base}.${target_format}"

    # 如果目标文件已存在，添加时间戳避免覆盖
    if [[ -f "$output_file" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        output_file="${file_dir}/${file_base}_${timestamp}.${target_format}"
        log_info "目标文件已存在，使用时间戳: $output_file"
    fi

    # 执行转换
    log_info "开始转换: $input_file → $output_file"

    local temp_dir
    temp_dir=$(mktemp -d)

    # 使用 LibreOffice 进行转换
    if soffice --headless --convert-to "$target_format" \
                --outdir "$temp_dir" \
                "$input_file" &>/dev/null; then

        # 移动转换结果到目标位置
        local converted_file="${temp_dir}/${file_base}.${target_format}"

        if [[ -f "$converted_file" ]]; then
            mv "$converted_file" "$output_file"
            log_success "转换成功: $output_file"
            rm -rf "$temp_dir"
            echo "$output_file"
            return 0
        else
            log_error "转换完成但文件未生成: $converted_file"
            rm -rf "$temp_dir"
            echo "$input_file"
            return 1
        fi
    else
        log_error "LibreOffice 转换失败: $input_file"
        rm -rf "$temp_dir"
        echo "$input_file"
        return 1
    fi
}

# ==================== 主入口 ====================

# 如果直接执行此脚本（而非 source）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 显示用法
    show_usage() {
        cat << EOF
用法: $0 <文件路径> <MIME 类型>

示例:
  $0 document.doc application/msword
  $0 spreadsheet.xls application/vnd.ms-excel
  $0 presentation.ppt application/vnd.ms-powerpoint

支持的转换:
  - .doc → .docx (application/msword)
  - .xls → .xlsx (application/vnd.ms-excel)
  - .ppt → .pptx (application/vnd.ms-powerpoint)

注意:
  - 需要 LibreOffice 安装
  - 如果 LibreOffice 不可用，将返回原文件路径
  - 转换后的文件与原文件在同一目录

返回值:
  - 输出转换后的文件路径
  - 转换失败或跳过时返回原文件路径
EOF
    }

    # 参数检查
    if [[ $# -lt 2 ]]; then
        log_error "参数不足"
        show_usage
        exit 1
    fi

    # 执行转换
    result=$(preconvert_legacy_format "$1" "$2")
    echo "$result"

    # 根据转换结果设置退出码
    if [[ "$result" == "$1" ]] && [[ "$(get_target_format "$2")" != "" ]]; then
        exit 1
    else
        exit 0
    fi
fi
