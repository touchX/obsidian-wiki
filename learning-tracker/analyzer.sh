#!/usr/bin/env bash
# Learning Analyzer — 分析用户学习行为，生成推荐和路径
# 使用方法: cd wiki && ../learning-tracker/analyzer.sh [command]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEARNING_TRACKER_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$LEARNING_TRACKER_DIR/config"
USER_ACTIVITY_FILE="${CONFIG_DIR}/user-activity.json"
WIKI_DIR="${WIKI_DIR:-wiki}"
LEARNING_WIKI_DIR="$WIKI_DIR/synthesis/user-learning"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq 未安装"
        exit 1
    fi
}

# 初始化学习目录结构
init_learning_structure() {
    mkdir -p "$LEARNING_WIKI_DIR"

    # 创建知识图谱页
    if [ ! -f "$LEARNING_WIKI_DIR/knowledge-graph.md" ]; then
        cat > "$LEARNING_WIKI_DIR/knowledge-graph.md" << 'EOF'
---
name: synthesis/user-learning/knowledge-graph
description: 用户知识主题关系图谱
type: synthesis
tags: [learning, user-profile, knowledge-graph]
created: "{{DATE}}"
updated: "{{DATE}}"
status: draft
---

# 知识主题关系图谱

> 本页记录用户探索过的主题及其相互关系

## 主题节点

| 主题 | 频率 | 关联主题 | 理解深度 |
|------|------|----------|----------|
| (待填充) | | | |

## 学习路径

```chart
(待生成)
```

## 最近探索

- (暂无数据)

## 更新日志

- {{DATE}}: 初始化
EOF
        log_info "已创建: $LEARNING_WIKI_DIR/knowledge-graph.md"
    fi

    # 创建推荐页面
    if [ ! -f "$LEARNING_WIKI_DIR/recommendations.md" ]; then
        cat > "$LEARNING_WIKI_DIR/recommendations.md" << 'EOF'
---
name: synthesis/user-learning/recommendations
description: 用户个性化学习推荐
type: synthesis
tags: [learning, recommendations]
created: "{{DATE}}"
updated: "{{DATE}}"
status: draft
---

# 学习推荐

> 基于用户查询历史和知识缺口自动生成

## 待探索主题

### 高频但未深入
- (分析后填充)

### 遗忘复习
- (超过 7 天未访问的主题)

### 前置知识缺失
- (用户询问的主题但缺少基础概念)

## 推荐理由

系统根据以下信号生成推荐:
1. 查询频率 > 3 次但未创建概念页
2. 连续询问相关主题（可能存在前置知识缺口）
3. 长时间未访问曾关注的主题

## 响应格式

当检测到以上模式时，主动向用户提议:

```
💡 建议: 似乎你对 [主题 A] 感兴趣，但 Wiki 中还没有相关基础概念页。
是否要我创建一个？
```

## 更新日志

- {{DATE}}: 初始化推荐系统
EOF
        log_info "已创建: $LEARNING_WIKI_DIR/recommendations.md"
    fi
}

# 从 user-activity.json 读取数据
read_user_data() {
    if [ ! -f "$USER_ACTIVITY_FILE" ]; then
        echo "{}"
        return
    fi
    cat "$USER_ACTIVITY_FILE"
}

# 更新知识图谱页面
update_knowledge_graph() {
    check_jq
    local data=$(read_user_data)

    local total=$(echo "$data" | jq '.total_queries // 0')
    local streak=$(echo "$data" | jq '.learning_streak // 0')
    local last_active=$(echo "$data" | jq -r '.last_active // "暂无"')
    local today=$(date '+%Y-%m-%d')

    # 检查文件是否存在
    if [ ! -f "$LEARNING_WIKI_DIR/knowledge-graph.md" ]; then
        log_warn "知识图谱文件不存在，跳过更新"
        return
    fi

    # 生成主题表格行
    local table_rows=$(echo "$data" | jq -r '
        .topic_frequencies as $freq
        | $freq | to_entries
        | sort_by(.value) | reverse
        | .[0:10]
        | map("| \(.key) | \(.value) | (待分析) | 学习中 |")
        | join("\n")
    ' 2>/dev/null)

    # 如果没有数据，使用占位符
    if [ -z "$table_rows" ]; then
        table_rows="| (暂无数据) | | | |"
    fi

    # 生成最近探索列表 (正确格式: - [[topic-name]])
    local recent_list=$(echo "$data" | jq -r '
        .recent_topics[:5] // []
        | map("- [[\(.topic)]]")
        | join("\n")
    ' 2>/dev/null)

    if [ -z "$recent_list" ]; then
        recent_list="- (暂无数据)"
    fi

    # 使用 awk 替换表格和最近探索内容
    awk -v rows="$table_rows" -v recent="$recent_list" '
    /^---$/ { if (!header_done) { print; getline; print; header_done=1; next } }
    /\| \(待填充\) \|/ { print rows; next }
    /^- \(暂无数据\)$/ { matched_recent=1; print recent; next }
    { if (!matched_recent) print }
    END { if (matched_recent) print "" }
    ' "$LEARNING_WIKI_DIR/knowledge-graph.md" > "$LEARNING_WIKI_DIR/knowledge-graph.md.tmp" 2>/dev/null || true

    # 如果 awk 成功，用临时文件替换
    if [ -f "$LEARNING_WIKI_DIR/knowledge-graph.md.tmp" ] && [ -s "$LEARNING_WIKI_DIR/knowledge-graph.md.tmp" ]; then
        mv "$LEARNING_WIKI_DIR/knowledge-graph.md.tmp" "$LEARNING_WIKI_DIR/knowledge-graph.md"
    fi

    # 更新 updated 字段
    sed -i "s/updated:.*/updated: $today/" "$LEARNING_WIKI_DIR/knowledge-graph.md" 2>/dev/null || true

    log_info "已更新知识图谱"
}

# 更新推荐页面
update_recommendations() {
    check_jq
    local data=$(read_user_data)
    local today=$(date '+%Y-%m-%d')

    # 检查文件是否存在
    if [ ! -f "$LEARNING_WIKI_DIR/recommendations.md" ]; then
        log_warn "推荐页面文件不存在，跳过更新"
        return
    fi

    # 分析高频但未深入的主题（频率>3但没有对应Wiki页面）
    local high_freq_lines=""
    local freq_topics=$(echo "$data" | jq -r '
        .topic_frequencies | to_entries
        | sort_by(.value) | reverse
        | .[] | select(.value > 3) | .key
    ' 2>/dev/null)

    if [ -n "$freq_topics" ]; then
        while IFS= read -r topic; do
            [ -z "$topic" ] && continue
            # 检查是否有对应的 Wiki 页面
            local has_page=false
            for dir in concepts entities sources synthesis; do
                if [ -d "$WIKI_DIR/$dir" ] && find "$WIKI_DIR/$dir" -name "*.md" -type f 2>/dev/null | xargs grep -l "^name:.*$topic" 2>/dev/null | grep -q .; then
                    has_page=true
                    break
                fi
            done

            if [ "$has_page" = false ]; then
                high_freq_lines="$high_freq_lines- [[$topic]] — 高频查询但 Wiki 中无相关概念页"$'\n'
            fi
        done <<< "$freq_topics"
    fi

    # 如果没有数据，使用占位符
    if [ -z "$high_freq_lines" ]; then
        high_freq_lines="- (暂无数据)"
    fi

    # 分析遗忘主题（7天未访问）
    local forgot_lines=""
    local recent_json=$(echo "$data" | jq -r '.recent_topics[] | @json' 2>/dev/null)

    if [ -n "$recent_json" ]; then
        while IFS= read -r entry; do
            [ -z "$entry" ] && continue
            local topic=$(echo "$entry" | jq -r '.topic' 2>/dev/null)
            local ts=$(echo "$entry" | jq -r '.timestamp' 2>/dev/null)
            if [ -n "$topic" ] && [ -n "$ts" ]; then
                local days_since=$(( ( $(date '+%s') - ts ) / 86400 ))
                if [ "$days_since" -ge 7 ]; then
                    forgot_lines="$forgot_lines- [[$topic]] — $days_since 天前查询，建议复习"$'\n'
                fi
            fi
        done <<< "$recent_json"
    fi

    if [ -z "$forgot_lines" ]; then
        forgot_lines="- (暂无数据)"
    fi

    # 构建更新后的文件内容
    local temp_file="$LEARNING_WIKI_DIR/recommendations.md.tmp"
    local in_placeholder=false
    local placeholder_type=""

    while IFS= read -r line; do
        # 检测占位符
        if echo "$line" | grep -q "^- (分析后填充)$"; then
            echo "$high_freq_lines" | sed 's/\\n/\n/g' >> "$temp_file"
            continue
        fi
        if echo "$line" | grep -q "^- (超过 7 天未访问的主题)$"; then
            echo "$forgot_lines" | sed 's/\\n/\n/g' >> "$temp_file"
            continue
        fi

        # 更新 updated 字段
        echo "$line" | sed "s/updated: {{DATE}}/updated: $today/" >> "$temp_file"
    done < "$LEARNING_WIKI_DIR/recommendations.md"

    mv "$temp_file" "$LEARNING_WIKI_DIR/recommendations.md" 2>/dev/null || true

    log_info "已更新推荐页面"
}

# 生成会话结束报告
generate_session_report() {
    local data=$(read_user_data)

    local total=$(echo "$data" | jq '.total_queries // 0')
    local today=$(date '+%Y-%m-%d')

    echo ""
    echo "═══════════════════════════════════════════"
    echo "         📚 本次会话学习总结"
    echo "═══════════════════════════════════════════"
    echo ""
    echo "  📅 日期: $today"
    echo "  📊 累计查询: $total 次"
    echo ""

    # 推荐探索
    echo "  💡 推荐探索:"
    local recs=$(echo "$data" | jq -r '
        .topic_frequencies as $freq
        | $freq | to_entries
        | sort_by(.value) | reverse
        | .[0:3]
        | map("    - \(.key) (查询 \(.value) 次)")
        | join("\n")
    ' 2>/dev/null)
    echo "$recs" || echo "    (暂无数据)"
    echo ""
    echo "═══════════════════════════════════════════"
    echo ""
}

# 主入口
main() {
    local command="${1:-}"

    case "$command" in
        init)
            init_learning_structure
            log_info "已初始化学习追踪结构"
            ;;
        update-graph)
            update_knowledge_graph
            ;;
        update-rec)
            update_recommendations
            ;;
        report)
            generate_session_report
            ;;
        analyze)
            check_jq
            init_learning_structure
            update_knowledge_graph
            update_recommendations
            generate_session_report
            ;;
        *)
            echo "Learning Analyzer — 学习分析器"
            echo ""
            echo "使用方法:"
            echo "  analyzer.sh init           # 初始化学习目录结构"
            echo "  analyzer.sh update-graph   # 更新知识图谱"
            echo "  analyzer.sh update-rec      # 更新推荐页面"
            echo "  analyzer.sh report          # 生成会话总结"
            echo "  analyzer.sh analyze         # 执行完整分析"
            ;;
    esac
}

main "$@"