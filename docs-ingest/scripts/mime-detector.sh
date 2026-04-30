#!/usr/bin/env bash
# MIME 类型检测模块
# 检测文件 MIME 类型，支持 file 命令和扩展名降级
#
# 依赖:
#   - file 命令（可选，未安装时降级到扩展名检测）

set -euo pipefail

# 检查 file 命令是否可用
if ! command -v file &> /dev/null; then
    echo "Warning: 'file' command not found, falling back to extension-based detection" >&2
fi

# MIME 类型检测函数
# 参数:
#   $1 - 文件路径
# 返回:
#   MIME 类型字符串
#   不可识别时返回 "unknown/missing"（文件不存在）或 "unknown/<ext>"（扩展名不匹配）
detect_mime_type() {
    local file="$1"
    local mime
    
    if [ ! -f "$file" ]; then
        echo "unknown/missing"
        return 1
    fi
    
    mime=$(file --mime-type -b "$file" 2>/dev/null)

    # 对于空文件、text/plain 或检测失败的情况，使用扩展名降级
    if [ -z "$mime" ] || [[ "$mime" == "text/plain" ]] || [[ "$mime" == "inode/x-empty" ]]; then
        local ext="${file##*.}"
        case "$ext" in
            docx) echo "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ;;
            xlsx) echo "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ;;
            pdf)  echo "application/pdf" ;;
            md)   echo "text/markdown" ;;
            doc)  echo "application/msword" ;;
            xls)  echo "application/vnd.ms-excel" ;;
            ppt)  echo "application/vnd.ms-powerpoint" ;;
            pptx) echo "application/vnd.openxmlformats-officedocument.presentationml.presentation" ;;
            html) echo "text/html" ;;
            htm)  echo "text/html" ;;
            txt)  echo "text/plain" ;;
            *)    echo "unknown/$ext" ;;
        esac
    else
        echo "$mime"
    fi
}

test_mime_detection() {
    echo "=== MIME 检测测试 ==="

    # 创建临时测试目录
    local test_dir=$(mktemp -d)
    trap "rm -rf '$test_dir'" EXIT

    local pass_count=0
    local fail_count=0

    # 测试用例: 文件名:预期MIME类型
    local tests=(
        "document.docx:application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "document.xlsx:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "document.pdf:application/pdf"
        "readme.md:text/markdown"
        "old.doc:application/msword"
        "data.xls:application/vnd.ms-excel"
    )

    for test in "${tests[@]}"; do
        local expected="${test##*:}"
        local filename="${test%%:*}"
        local test_file="$test_dir/$filename"

        # 创建测试文件（写入一些内容以便 file 命令识别）
        echo "test content" > "$test_file"

        # 执行检测
        local result
        result=$(detect_mime_type "$test_file")

        # 验证结果
        if [[ "$result" == "$expected" ]]; then
            echo "✅ PASS: $filename → $result"
            ((pass_count++)) || true
        else
            echo "❌ FAIL: $filename → $result (expected: $expected)"
            ((fail_count++)) || true
        fi
    done

    # 测试不存在的文件
    local missing_result
    missing_result=$(detect_mime_type "$test_dir/nonexistent.txt" 2>&1 || true)
    if [[ "$missing_result" == "unknown/missing" ]]; then
        echo "✅ PASS: 不存在的文件 → $missing_result"
        ((pass_count++)) || true
    else
        echo "❌ FAIL: 不存在的文件 → $missing_result (expected: unknown/missing)"
        ((fail_count++)) || true
    fi

    # 输出总结
    echo ""
    echo "=== 测试总结 ==="
    echo "通过: $pass_count"
    echo "失败: $fail_count"

    if [[ $fail_count -eq 0 ]]; then
        echo "✅ 所有测试通过"
        return 0
    else
        echo "❌ 有 $fail_count 个测试失败"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_mime_detection
fi
