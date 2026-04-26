#!/usr/bin/env bash
# Wiki Lint Tool — 检查 Wiki 健康状况
# 使用方法: cd wiki && ../scripts/wiki-lint.sh

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

while IFS= read -r -d '' file; do
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
done < <(find "$WIKI_DIR" -type f -name "*.md" -print0)

if [ $missing_frontmatter -eq 0 ] && [ $missing_name -eq 0 ] && [ $missing_description -eq 0 ] && [ $missing_type -eq 0 ]; then
    echo "| 检查项 | 状态 |" >> "$REPORT_FILE"
    echo "|--------|------|" >> "$REPORT_FILE"
    echo "| 有 frontmatter 页面 | $((total - missing_frontmatter)) |" >> "$REPORT_FILE"
    echo "| 缺失 frontmatter | 0 |" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 3. 交叉引用检查
echo "## 链接健康" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

temp_refs=$(mktemp)
find "$WIKI_DIR" -type f -name "*.md" -exec grep -ho '\[\[[^]]*\]\]' {} \; | sort -u > "$temp_refs"

broken_refs=0
while IFS= read -r ref; do
    page_name=$(echo "$ref" | sed 's/\[\[//g' | sed 's/\]\]//g' | sed 's/|.*//')

    if ! find "$WIKI_DIR" -type f -name "${page_name}.md" | grep -q .; then
        echo "- $ref: 目标页面不存在" >> "$REPORT_FILE"
        broken_refs=$((broken_refs + 1))
    fi
done < "$temp_refs"

rm -f "$temp_refs"

if [ $broken_refs -eq 0 ]; then
    echo "- 所有 \`[[wikilinks]]\` 引用正常" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 4. 总结
echo "## 问题清单" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 级别 | 问题 |" >> "$REPORT_FILE"
echo "|------|------|" >> "$REPORT_FILE"

total_issues=$((missing_frontmatter + missing_name + missing_description + missing_type + broken_refs))

if [ $total_issues -eq 0 ]; then
    echo "| ✅ | 无问题发现 |" >> "$REPORT_FILE"
else
    echo "| ⚠️ | 发现 $total_issues 个问题 |" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "## 建议" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- 定期运行 \`bash scripts/wiki-lint.sh\` 保持健康" >> "$REPORT_FILE"
echo "- 新页面添加完整 frontmatter" >> "$REPORT_FILE"
echo "- Source 字段指向 archive/ 中的实际文件" >> "$REPORT_FILE"
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
    echo "⚠️  发现 $total_issues 个问题"
    exit 1
fi
