#!/usr/bin/env bash
# MIME 类型检测模块
# 检测文件 MIME 类型，支持 file 命令和扩展名降级

set -euo pipefail

detect_mime_type() {
    local file="$1"
    local mime
    
    if [ ! -f "$file" ]; then
        echo "unknown/missing"
        return 1
    fi
    
    mime=$(file --mime-type -b "$file" 2>/dev/null)
    
    if [ -z "$mime" ] || [[ "$mime" == "text/plain" ]]; then
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
        echo "测试: $filename"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_mime_detection
fi
