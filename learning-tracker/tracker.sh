#!/usr/bin/env bash
# Learning Tracker — 内部使用（由 learning-tracker skill 调用）
# 不应直接调用，通过 learning-tracker skill 使用
#
# 内部命令:
#   record <topic> [difficulty]    # 记录查询
#   analyze                        # 分析并生成推荐
#   recommend                      # 获取推荐
#   init                           # 初始化追踪文件

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
USER_ACTIVITY_FILE="${CONFIG_DIR}/user-activity.json"
WIKI_DIR="${WIKI_DIR:-wiki}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 跨平台 sed -i 兼容
sed_inplace() {
    if sed --version &>/dev/null 2>&1; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# 确保 jq 可用
check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq 未安装，请先安装: brew install jq 或 apt install jq"
        exit 1
    fi
}

# 初始化 learning tracker Wiki 目录结构（在 tracker.sh 中调用）
init_learning_structure_from_tracker() {
    local LEARNING_WIKI_DIR="${WIKI_DIR:-wiki}/synthesis/user-learning"
    mkdir -p "$LEARNING_WIKI_DIR"

    local today=$(date '+%Y-%m-%d')

    # 创建知识图谱页
    if [ ! -f "$LEARNING_WIKI_DIR/knowledge-graph.md" ]; then
        cat > "$LEARNING_WIKI_DIR/knowledge-graph.md" << EOF
---
name: synthesis/user-learning/knowledge-graph
description: 用户知识主题关系图谱
type: synthesis
tags: [learning, user-profile, knowledge-graph]
created: $today
updated: $today
status: draft
---

# 知识主题关系图谱

> 本页记录用户探索过的主题及其相互关系

## 主题节点

| 主题 | 频率 | 关联主题 | 理解深度 |
|------|------|----------|----------|
| (待填充) | | | |

## 学习路径

- (待生成)

## 最近探索

- (暂无数据)

## 更新日志

- $today: 初始化
EOF
        log_info "已创建: $LEARNING_WIKI_DIR/knowledge-graph.md"
    fi

    # 创建推荐页面
    if [ ! -f "$LEARNING_WIKI_DIR/recommendations.md" ]; then
        cat > "$LEARNING_WIKI_DIR/recommendations.md" << EOF
---
name: synthesis/user-learning/recommendations
description: 用户个性化学习推荐
type: synthesis
tags: [learning, recommendations]
created: $today
updated: $today
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

\`\`\`
💡 建议: 似乎你对 [主题 A] 感兴趣，但 Wiki 中还没有相关基础概念页。
是否要我创建一个？
\`\`\`

## 更新日志

- $today: 初始化推荐系统
EOF
        log_info "已创建: $LEARNING_WIKI_DIR/recommendations.md"
    fi
}

# 初始化追踪文件
init_tracker() {
    mkdir -p "$CONFIG_DIR"

    if [ ! -f "$USER_ACTIVITY_FILE" ]; then
        cat > "$USER_ACTIVITY_FILE" << 'EOF'
{
  "_comment": "用户学习活动追踪 - 轻量积分系统",
  "schema_version": "1.0",
  "user_id": "default",
  "last_active": "",
  "created": "",
  "topic_frequencies": {},
  "weak_areas": [],
  "learning_streak": 0,
  "total_queries": 0,
  "query_history": [],
  "recent_topics": []
}
EOF
        log_info "已初始化用户活动追踪: $USER_ACTIVITY_FILE"
    else
        log_info "追踪文件已存在: $USER_ACTIVITY_FILE"
    fi

    # 同时初始化 learning tracker Wiki 目录结构
    init_learning_structure_from_tracker
}

# 获取当前日期
get_date() {
    date '+%Y-%m-%d'
}

# 获取当前时间戳
get_timestamp() {
    date '+%s'
}

# 记录查询事件
record_query() {
    local topic="$1"
    local difficulty="${2:-3}"

    check_jq
    init_tracker

    if [ -z "$topic" ]; then
        log_error "topic 不能为空"
        return 1
    fi

    local current_date=$(get_date)
    local current_time=$(get_timestamp)

    # 规范化 topic（转小写，移除特殊字符）
    local normalized_topic=$(echo "$topic" | tr '[:upper:]' '[:lower]' | sed 's/[^a-z0-9-]/-/g')

    # 读取现有数据
    local existing_data=$(cat "$USER_ACTIVITY_FILE")

    # 获取当前频率并计算新频率
    local current_freq=$(echo "$existing_data" | jq -r --arg t "$normalized_topic" '.topic_frequencies[$t] // 0')
    local new_freq=$((current_freq + 1))

    # 获取当前 total_queries
    local current_total=$(echo "$existing_data" | jq '.total_queries // 0')

    # 在单次 jq 调用中更新 topic_frequencies 和 total_queries
    local new_topic_freq=$(echo "$existing_data" | jq \
        --arg t "$normalized_topic" \
        --argjson v "$new_freq" \
        --argjson total "$((current_total + 1))" \
        '.topic_frequencies[$t] = $v | .total_queries = $total')

    # 更新 last_active
    new_topic_freq=$(echo "$new_topic_freq" | jq --arg d "$current_date" '.last_active = $d')

    # 更新 created（如果是首次）
    local created=$(echo "$new_topic_freq" | jq -r '.created // empty')
    if [ -z "$created" ]; then
        new_topic_freq=$(echo "$new_topic_freq" | jq --arg d "$current_date" '.created = $d')
    fi

    # 更新最近主题（保留最后 10 个）
    # 先构建新条目，然后与现有 recent_topics 合并去重
    local new_topic_entry="{\"topic\":\"$normalized_topic\",\"timestamp\":$current_time}"
    local recent=$(echo "$new_topic_freq" | jq --argjson n "$new_topic_entry" '
        .recent_topics |= (
            ([$n] + (.recent_topics // []))
            | unique_by(.topic)
            | .[0:10]
        )')

    # 更新学习连续天数
    local last_active_date=$(echo "$recent" | jq -r '.last_active // empty')
    local current_streak=$(echo "$recent" | jq '.learning_streak // 0')

    # 计算日期差异
    local new_streak=1  # 默认从1开始
    if [ -n "$last_active_date" ]; then
        local last_ts
        if date -d "$last_active_date" '+%s' &>/dev/null 2>&1; then
            last_ts=$(date -d "$last_active_date" '+%s')
        else
            last_ts=$(date -j -f '%Y-%m-%d' "$last_active_date" '+%s' 2>/dev/null || echo 0)
        fi
        local diff=$(( (current_time - last_ts) / 86400 ))
        if [ "$diff" -eq 0 ]; then
            # 同一天，保持 streak
            new_streak=$current_streak
        elif [ "$diff" -eq 1 ]; then
            # 昨天，连续+1
            new_streak=$((current_streak + 1))
        else
            # 超过1天，重新计算
            new_streak=1
        fi
    fi

    # 更新 learning_streak
    local with_streak=$(echo "$recent" | jq --argjson s "$new_streak" '.learning_streak = $s')

    # 处理 weak_areas: 当 difficulty >= 4 时更新
    local with_weak_areas="$with_streak"
    if [ "$difficulty" -ge 4 ]; then
        # 检查是否已在 weak_areas 中（使用数组长度判断更可靠）
        local existing_count=$(echo "$with_streak" | jq --arg t "$normalized_topic" '
            [.weak_areas[] | select(.topic == $t)] | length')

        if [ "$existing_count" -gt 0 ]; then
            # 更新已有条目
            with_weak_areas=$(echo "$with_streak" | jq --arg t "$normalized_topic" --argjson d "$difficulty" '
                .weak_areas |= map(
                    if .topic == $t then
                        .count += 1 |
                        .avg_difficulty = ((.avg_difficulty * (.count - 1) + $d) / .count)
                    else . end
                )')
        else
            # 添加新条目
            local weak_entry="{\"topic\":\"$normalized_topic\",\"count\":1,\"avg_difficulty\":$difficulty}"
            with_weak_areas=$(echo "$with_streak" | jq --argjson w "$weak_entry" \
                '.weak_areas = ([$w] + (.weak_areas // []))')
        fi
    fi

    # 记录到历史（保留最后 100 条）
    local history_entry="{\"topic\":\"$normalized_topic\",\"difficulty\":$difficulty,\"timestamp\":$current_time,\"date\":\"$current_date\"}"
    local new_history=$(echo "$with_weak_areas" | jq --argjson e "$history_entry" \
        '.query_history = (([$e] + (.query_history // [])) | .[0:100])')

    # 保存更新
    echo "$new_history" > "$USER_ACTIVITY_FILE"

    # 同时更新 Wiki 页面的 frontmatter
    update_wiki_page_query "$normalized_topic" "$current_date"

    log_info "已记录查询: $normalized_topic (频率: $new_freq, 难度: $difficulty, 连续: $new_streak 天)"
}

# 更新 Wiki 页面的 query_count
update_wiki_page_query() {
    local topic="$1"
    local current_date="$2"

    # 查找匹配的 Wiki 页面
    local page_path=""
    local match_type=""

    for dir in concepts entities sources synthesis guides tips tutorial; do
        if [ -d "$WIKI_DIR/$dir" ]; then
            # 1. 先尝试精确匹配文件名（如 javascript.md → javascript）
            local found=""
            local match_count=0
            while IFS= read -r f; do
                local fname=$(basename "$f" .md)
                if [[ "$fname" == "$topic" ]]; then
                    found="$f"
                    match_count=$((match_count + 1))
                fi
            done < <(find "$WIKI_DIR/$dir" -name "*.md" -type f 2>/dev/null)

            if [ -n "$found" ] && [ "$match_count" -eq 1 ]; then
                page_path="$found"
                match_type="exact_filename"
                break
            fi

            # 2. 如果没找到，尝试模糊匹配 name 字段（不区分大小写）
            if [ -z "$page_path" ]; then
                found=""
                match_count=0
                while IFS= read -r f; do
                    local name_val=$(grep "^name:" "$f" 2>/dev/null | head -1 | sed 's/name: *//i' | tr -d ' ')
                    # 规范化 name 字段后对比（如 JavaScript → javascript）
                    local norm_name=$(echo "$name_val" | tr '[:upper:]' '[:lower]' | sed 's/[^a-z0-9-]/-/g')
                    if [[ "$norm_name" == "$topic" ]]; then
                        found="$f"
                        match_count=$((match_count + 1))
                    fi
                done < <(find "$WIKI_DIR/$dir" -name "*.md" -type f 2>/dev/null)

                if [ -n "$found" ] && [ "$match_count" -eq 1 ]; then
                    page_path="$found"
                    match_type="name_field"
                    break
                elif [ "$match_count" -gt 1 ]; then
                    log_warn "主题 '$topic' 在 $dir/ 中有 $match_count 个匹配，跳过更新"
                fi
            fi

            if [ -n "$page_path" ]; then
                break
            fi
        fi
    done

    if [ -z "$page_path" ]; then
        return 0  # 没找到对应页面，不报错
    fi

    # 读取并更新 frontmatter
    if grep -q "^query_count:" "$page_path" 2>/dev/null; then
        # 更新现有值
        local current_count=$(grep "^query_count:" "$page_path" | head -1 | sed 's/query_count: *//' | tr -d ' ')
        local new_count=$((current_count + 1))
        sed_inplace "s/^query_count:.*/query_count: $new_count/" "$page_path"
    else
        # 在第一个 --- 之后添加
        sed_inplace "1a\\query_count: 1" "$page_path"
    fi

    # 更新 last_queried
    if grep -q "^last_queried:" "$page_path" 2>/dev/null; then
        sed_inplace "s/^last_queried:.*/last_queried: $current_date/" "$page_path"
    else
        sed_inplace "1a\\last_queried: $current_date" "$page_path"
    fi
}

# 分析学习数据
analyze_learning() {
    check_jq

    if [ ! -f "$USER_ACTIVITY_FILE" ]; then
        log_warn "追踪文件不存在，请先运行 init"
        return 1
    fi

    local data=$(cat "$USER_ACTIVITY_FILE")

    echo ""
    echo "═══════════════════════════════════════"
    echo "        用户学习分析报告"
    echo "═══════════════════════════════════════"
    echo ""

    # 基础统计
    local total=$(echo "$data" | jq '.total_queries')
    local streak=$(echo "$data" | jq '.learning_streak')
    local last_active=$(echo "$data" | jq -r '.last_active')

    echo "📊 基础统计"
    echo "   总查询数: $total"
    echo "   学习连续: $streak 天"
    echo "   最近活跃: $last_active"
    echo ""

    # 热门主题
    echo "🔥 热门主题 TOP5"
    echo "$data" | jq -r '.topic_frequencies | to_entries | sort_by(.value) | reverse | .[0:5] | .[] | "   \(.key): \(.value) 次"' 2>/dev/null || echo "   暂无数据"
    echo ""

    # 知识缺口分析
    echo "⚠️  知识缺口检测"
    local weak_areas=$(echo "$data" | jq '.weak_areas')
    if [ "$weak_areas" != "[]" ] && [ "$weak_areas" != "null" ]; then
        echo "$weak_areas" | jq -r '.[] | "   \(.topic): 询问 \(.count) 次，平均难度 \(.avg_difficulty)"'
    else
        echo "   暂无缺口数据（需积累更多查询）"
    fi
    echo ""

    # 遗忘提醒
    echo "🔔 遗忘提醒"
    local recent=$(echo "$data" | jq -r '.recent_topics // []')

    if [ "$recent" != "[]" ] && [ "$recent" != "null" ]; then
        local current_time=$(get_timestamp)
        echo "$recent" | jq -r '.[] | @json' 2>/dev/null | while read -r entry; do
            local topic=$(echo "$entry" | jq -r '.topic')
            local ts=$(echo "$entry" | jq -r '.timestamp')
            local days_since=$(( (current_time - ts) / 86400 ))
            if [ "$days_since" -ge 7 ]; then
                echo "   ⏰ [$days_since 天前] $topic — 建议复习"
            fi
        done
    else
        echo "   暂无数据"
    fi

    echo ""
    echo "═══════════════════════════════════════"
    echo ""
}

# 获取推荐
get_recommendations() {
    check_jq

    if [ ! -f "$USER_ACTIVITY_FILE" ]; then
        echo "[]"
        return
    fi

    local data=$(cat "$USER_ACTIVITY_FILE")

    # 生成推荐列表
    local recommendations=$(echo "$data" | jq '{
        suggestions: [
            (.topic_frequencies | to_entries | sort_by(.value) | reverse | .[0:3] | .[] | {
                type: "hot",
                topic: .key,
                reason: "高频查询主题"
            }),
            (.weak_areas[] // empty | {
                type: "review",
                topic: .topic,
                reason: "多次提问但理解困难的主题"
            })
        ] | unique_by(.topic) | .[0:5]
    }')

    echo "$recommendations" | jq -r '.suggestions[] | "- [\(.type)] \(.topic): \(.reason)"' 2>/dev/null || echo "暂无推荐"
}

# 主入口
main() {
    local command="${1:-}"

    case "$command" in
        init)
            init_tracker
            ;;
        record)
            record_query "$2" "$3"
            ;;
        analyze)
            analyze_learning
            ;;
        recommend)
            get_recommendations
            ;;
        *)
            echo "Learning Tracker — 用户学习活动追踪"
            echo ""
            echo "使用方法:"
            echo "  tracker.sh init                  # 初始化追踪文件"
            echo "  tracker.sh record <topic> [难度]  # 记录查询事件"
            echo "  tracker.sh analyze                # 分析学习数据"
            echo "  tracker.sh recommend              # 获取推荐"
            echo ""
            echo "示例:"
            echo "  tracker.sh record javascript 3"
            echo "  tracker.sh analyze"
            ;;
    esac
}

main "$@"