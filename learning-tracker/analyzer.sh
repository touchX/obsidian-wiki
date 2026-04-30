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

    # 生成主题表格
    local topic_table=$(echo "$data" | jq -r '
        .topic_frequencies as $freq
        | $freq | to_entries
        | sort_by(.value) | reverse
        | .[0:10]
        | map("| \(.key) | \(.value) | (待分析) | 学习中 |")
        | join("\n")
    ')

    # 最近探索
    local recent_topics=$(echo "$data" | jq -r '
        .recent_topics[:5] // []
        | map("- [[\(.)]]") | join("\n")
    ')

    # 替换占位符
    if [ -f "$LEARNING_WIKI_DIR/knowledge-graph.md" ]; then
        local today=$(date '+%Y-%m-%d')

        # 使用更精确的 sed 替换
        sed -i "s/| (待填充) |/$(echo "$topic_table" | head -1 || echo '| (暂无数据) |')/g" "$LEARNING_WIKI_DIR/knowledge-graph.md" 2>/dev/null || true

        # 更新最近探索
        if [ "$recent_topics" != "" ]; then
            sed -i "s/- (暂无数据)/$(echo "$recent_topics" | head -5)/g" "$LEARNING_WIKI_DIR/knowledge-graph.md" 2>/dev/null || true
        fi

        # 更新元数据
        sed -i "s/updated: {{DATE}}/updated: $today/g" "$LEARNING_WIKI_DIR/knowledge-graph.md" 2>/dev/null || true

        log_info "已更新知识图谱"
    fi
}

# 更新推荐页面
update_recommendations() {
    check_jq
    local data=$(read_user_data)

    # 分析高频但未深入的主题（频率>3但没有对应Wiki页面）
    local high_freq_low_depth=""
    echo "$data" | jq -r '
        .topic_frequencies | to_entries
        | sort_by(.value) | reverse
        | .[] | select(.value > 3)
        | .key
    ' 2>/dev/null | while read -r topic; do
        # 检查是否有对应的 Wiki 页面
        local has_page=false
        for dir in concepts entities sources synthesis; do
            if find "$WIKI_DIR/$dir" -name "*.md" -type f 2>/dev/null | xargs grep -l "^name:.*$topic" 2>/dev/null | grep -q .; then
                has_page=true
                break
            fi
        done

        if [ "$has_page" = false ]; then
            high_freq_low_depth="$high_freq_low_depth\n- [[$topic]] — 高频查询但 Wiki 中无相关概念页"
        fi
    done

    # 分析遗忘主题（7天未访问）
    local current_time=$(date '+%s')
    local forgot_topics=""
    echo "$data" | jq -r '.recent_topics[] | @json' 2>/dev/null | while read -r entry; do
        local topic=$(echo "$entry" | jq -r '.topic')
        local ts=$(echo "$entry" | jq -r '.timestamp')
        local days_since=$(( (current_time - ts) / 86400 ))
        if [ "$days_since" -ge 7 ]; then
            forgot_topics="$forgot_topics\n- [[$topic]] — $days_since 天前查询，建议复习"
        fi
    done

    # 更新推荐页面
    if [ -f "$LEARNING_WIKI_DIR/recommendations.md" ]; then
        local today=$(date '+%Y-%m-%d')

        # 替换高频但未深入部分
        if [ -n "$high_freq_low_depth" ]; then
            sed -i "s/- (分析后填充)/$(echo "$high_freq_low_depth" | tail -5)/g" "$LEARNING_WIKI_DIR/recommendations.md" 2>/dev/null || true
        fi

        # 替换遗忘复习部分
        if [ -n "$forgot_topics" ]; then
            sed -i "s/- (超过 7 天未访问的主题)/$(echo "$forgot_topics" | tail -5)/g" "$LEARNING_WIKI_DIR/recommendations.md" 2>/dev/null || true
        fi

        # 更新时间
        sed -i "s/updated: {{DATE}}/updated: $today/g" "$LEARNING_WIKI_DIR/recommendations.md" 2>/dev/null || true

        log_info "已更新推荐页面"
    fi
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