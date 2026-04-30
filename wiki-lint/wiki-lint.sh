#!/usr/bin/env bash
# Wiki Lint Tool — 检查 Wiki 健康状况
# 使用方法: cd wiki && ../scripts/wiki-lint.sh
# 或从项目根目录: bash wiki-lint/wiki-lint.sh

set -euo pipefail

WIKI_DIR="${WIKI_DIR:-wiki}"
REPORT_FILE="${WIKI_DIR}/WIKI-LINT-REPORT.md"

echo "# Wiki Lint Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "> 生成时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 统计函数
count_pages() {
    local dir=$1
    find "$WIKI_DIR/$dir" -type f -name "*.md" 2>/dev/null | wc -l
}

# 1. 页面统计
echo "## 页面统计" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 分类 | 页面数 |" >> "$REPORT_FILE"
echo "|------|--------|" >> "$REPORT_FILE"
total=0
for dir in concepts entities sources synthesis guides tips tutorial; do
    count=$(count_pages "$dir")
    total=$((total + count))
    echo "| $dir/ | $count |" >> "$REPORT_FILE"
done
echo "| **总计** | **$total** |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. Frontmatter 检查
echo "## Frontmatter 检查" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

missing_frontmatter=0
missing_name=0
missing_description=0
missing_type=0
missing_tags=0
missing_created=0
missing_updated=0

while IFS= read -r -d '' file; do
    # 跳过报告文件本身
    if [[ "$file" == *"/WIKI-LINT-REPORT.md" ]] || [[ "$file" == *"WIKI-LINT-REPORT.md" ]]; then
        continue
    fi

    if ! grep -q "^---$" "$file"; then
        echo "- $file: 缺少 frontmatter" >> "$REPORT_FILE"
        missing_frontmatter=$((missing_frontmatter + 1))
        continue
    fi

    if ! grep -q "^name:" "$file"; then
        echo "- $file: 缺少 name 字段" >> "$REPORT_FILE"
        missing_name=$((missing_name + 1))
    fi

    if ! grep -q "^description:" "$file"; then
        echo "- $file: 缺少 description 字段" >> "$REPORT_FILE"
        missing_description=$((missing_description + 1))
    fi

    if ! grep -q "^type:" "$file"; then
        echo "- $file: 缺少 type 字段" >> "$REPORT_FILE"
        missing_type=$((missing_type + 1))
    fi

    if ! grep -q "^tags:" "$file"; then
        echo "- $file: 缺少 tags 字段" >> "$REPORT_FILE"
        missing_tags=$((missing_tags + 1))
    fi

    if ! grep -q "^created:" "$file"; then
        echo "- $file: 缺少 created 字段" >> "$REPORT_FILE"
        missing_created=$((missing_created + 1))
    fi

    if ! grep -q "^updated:" "$file"; then
        echo "- $file: 缺少 updated 字段" >> "$REPORT_FILE"
        missing_updated=$((missing_updated + 1))
    fi
done < <(find "$WIKI_DIR" -type f -name "*.md" -print0)

echo "| 检查项 | 数量 |" >> "$REPORT_FILE"
echo "|--------|------|" >> "$REPORT_FILE"
echo "| 有 frontmatter（可能缺字段） | $((total - missing_frontmatter)) |" >> "$REPORT_FILE"
echo "| 缺失 frontmatter | $missing_frontmatter |" >> "$REPORT_FILE"
echo "| 缺失 name | $missing_name |" >> "$REPORT_FILE"
echo "| 缺失 description | $missing_description |" >> "$REPORT_FILE"
echo "| 缺失 type | $missing_type |" >> "$REPORT_FILE"
echo "| 缺失 tags | $missing_tags |" >> "$REPORT_FILE"
echo "| 缺失 created | $missing_created |" >> "$REPORT_FILE"
echo "| 缺失 updated | $missing_updated |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 3. 交叉引用检查
echo "## 链接健康" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

temp_refs=$(mktemp)
find "$WIKI_DIR" -type f -name "*.md" -exec grep -ho '\[\[[^]]*\]\]' {} \; | \
    sed 's/\[\[//g; s/\]\]//g; s/|.*//' | sort -u > "$temp_refs"

broken_refs=0
while IFS= read -r page_name; do
    # 跳过空链接和示例
    [ -z "$page_name" ] && continue
    [[ "$page_name" == *"..."* ]] && continue
    [[ "$page_name" == "xxx" ]] && continue

    # 跳过外部链接
    [[ "$page_name" == http* ]] || [[ "$page_name" == ../* ]] || [[ "$page_name" == /* ]] && continue

    # 跳过目录链接 (如 concepts/) -> 实际文件是 concepts/wiki-concept
    # 但 topic/sub 这种子目录链接需要正常检查
    if [[ "$page_name" == */ ]]; then
        # 检查是否为单层目录（如 concepts/），跳过
        # 多层路径（如 topic/sub/）不应跳过，因为可能是 topic/sub.md
        if [[ "$page_name" != */*/* ]]; then
            continue
        fi
    fi

    if ! find "$WIKI_DIR" -type f -name "${page_name}.md" 2>/dev/null | grep -q .; then
        echo "- \`[[$page_name]]\`: 目标页面不存在" >> "$REPORT_FILE"
        broken_refs=$((broken_refs + 1))
    fi
done < "$temp_refs"

rm -f "$temp_refs"

if [ $broken_refs -eq 0 ]; then
    echo "- 所有 \`[[wikilinks]]\` 引用正常 ✅" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 4. 孤立页面检测
echo "## 孤立页面" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

temp_all=$(mktemp)
temp_linked=$(mktemp)
temp_orphan=$(mktemp)

# 列出所有页面（不含扩展名）
find "$WIKI_DIR" -name "*.md" -type f | sed 's|\.md$||; s|'"$WIKI_DIR"'/||' | sort > "$temp_all"

# 列出被引用的页面
find "$WIKI_DIR" -name "*.md" -type f -exec grep -ho '\[\[[^]]*\]\]' {} \; | \
    sed 's/\[\[//g; s/\]\]//g; s/|.*//' | sort -u > "$temp_linked"

# 找出孤立页面（未被任何页面引用）
comm -23 "$temp_all" "$temp_linked" > "$temp_orphan"

orphan_count=$(wc -l < "$temp_orphan" 2>/dev/null || echo 0)
if [ "$orphan_count" -eq 0 ] || [ -z "$(cat "$temp_orphan")" ]; then
    echo "- 无孤立页面 ✅" >> "$REPORT_FILE"
else
    while IFS= read -r page; do
        [ -z "$page" ] && continue
        echo "- \`$page.md\` — 无入站链接" >> "$REPORT_FILE"
    done < "$temp_orphan"
fi

rm -f "$temp_all" "$temp_linked" "$temp_orphan"
echo "" >> "$REPORT_FILE"

# 5. 矛盾检测
echo "## 知识矛盾检测" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

challenged_count=$(find "$WIKI_DIR" -name "*.md" -type f -exec grep -l "^status: challenged" {} \; 2>/dev/null | wc -l)
warning_count=$(find "$WIKI_DIR" -name "*.md" -type f -exec grep -c "\[!warning\]" {} \; 2>/dev/null | awk -F: '{sum+=$2} END{print sum+0}')

if [ "$challenged_count" -eq 0 ] && [ "$warning_count" -eq 0 ]; then
    echo "- 无矛盾标记 ✅" >> "$REPORT_FILE"
else
    if [ "$challenged_count" -gt 0 ]; then
        echo "- 发现 $challenged_count 个 \`status: challenged\` 页面" >> "$REPORT_FILE"
        find "$WIKI_DIR" -name "*.md" -type f -exec grep -l "^status: challenged" {} \; 2>/dev/null | \
            sed 's|'"$WIKI_DIR"'/||' | while read f; do
                echo "  - $f" >> "$REPORT_FILE"
            done
    fi
    if [ "$warning_count" -gt 0 ]; then
        echo "- 发现 $warning_count 个 \`> [!warning]\` 标记" >> "$REPORT_FILE"
    fi
fi
echo "" >> "$REPORT_FILE"

# 6. Source 路径检查
echo "## Source 引用检查" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

missing_sources=0
while IFS= read -r -d '' file; do
    # 跳过报告文件本身
    [[ "$file" == *"/WIKI-LINT-REPORT.md" ]] || [[ "$file" == *"WIKI-LINT-REPORT.md" ]] && continue

    source_path=$(grep "^source:" "$file" | sed 's/source: *//' | tr -d ' ')
    if [ -n "$source_path" ] && [ "$source_path" != "conversation" ]; then
        # 转换相对路径为绝对路径检查
        # 支持 ../ 多层相对路径
        if [ ! -f "$source_path" ]; then
            # 尝试相对于文件所在目录解析
            file_dir=$(dirname "$file")
            resolved_path="$file_dir/$source_path"
            # 规范化路径（移除多余的 ../ 和 ./）
            resolved_path=$(cd "$file_dir" 2>/dev/null && realpath -m "$source_path" 2>/dev/null || echo "$resolved_path")
            if [ ! -f "$resolved_path" ]; then
                echo "- $file: source 指向的文件不存在 ($source_path)" >> "$REPORT_FILE"
                missing_sources=$((missing_sources + 1))
            fi
        fi
    fi
done < <(find "$WIKI_DIR" -name "*.md" -print0)

if [ $missing_sources -eq 0 ]; then
    echo "- 所有 source 路径有效 ✅" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 7. 总结
echo "## 问题清单" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 级别 | 问题 |" >> "$REPORT_FILE"
echo "|------|------|" >> "$REPORT_FILE"

total_issues=$((missing_frontmatter + missing_name + missing_description + missing_type + missing_tags + missing_created + missing_updated + broken_refs + orphan_count + missing_sources))

if [ $total_issues -eq 0 ]; then
    echo "| ✅ | 无问题发现 |" >> "$REPORT_FILE"
else
    echo "| ⚠️ | 发现 $total_issues 个问题 |" >> "$REPORT_FILE"
    echo "|   | - Frontmatter 问题: $((missing_name + missing_description + missing_type + missing_tags + missing_created + missing_updated)) |" >> "$REPORT_FILE"
    echo "|   | - 失效链接: $broken_refs |" >> "$REPORT_FILE"
    echo "|   | - 孤立页面: $orphan_count |" >> "$REPORT_FILE"
    echo "|   | - Source 路径错误: $missing_sources |" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "## 建议" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- 定期运行 \`bash scripts/wiki-lint.sh\` 保持健康" >> "$REPORT_FILE"
echo "- 新页面添加完整 frontmatter（name, description, type, tags, created, updated）" >> "$REPORT_FILE"
echo "- 为孤立页面添加交叉引用链接到相关页面" >> "$REPORT_FILE"
echo "- Source 字段指向 archive/ 中的实际文件" >> "$REPORT_FILE"
echo "- challenged 状态页面应及时验证或标记为 stable/superseded" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "*Last updated: $(date '+%Y-%m-%d')*" >> "$REPORT_FILE"

echo ""
echo "Wiki Lint 完成！报告已生成: $REPORT_FILE"

if [ $total_issues -eq 0 ]; then
    echo "✅ Wiki 健康状况良好"
    exit 0
else
    echo "⚠️  发现 $total_issues 个问题，请查看报告"
    exit 1
fi