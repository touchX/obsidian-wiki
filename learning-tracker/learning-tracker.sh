#!/usr/bin/env bash
# Learning Tracker — 用户学习活动追踪
# 用于记录用户的查询主题、频率、知识缺口，生成推荐
#
# 使用方法:
#   learning-tracker.sh record <topic> [difficulty]    # 记录查询
#   learning-tracker.sh analyze                        # 分析并生成推荐
#   learning-tracker.sh recommend                      # 获取推荐
#   learning-tracker.sh init                           # 初始化追踪文件

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

# 确保 jq 可用
check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq 未安装，请先安装: brew install jq 或 apt install jq"
        exit 1
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
    local normalized_topic=$(echo "$topic" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

    # 读取现有数据
    local existing_data=$(cat "$USER_ACTIVITY_FILE")

    # 更新总查询数
    local total_queries=$(echo "$existing_data" | jq '.total_queries // 0')
    total_queries=$((total_queries + 1))

    # 更新主题频率
    local current_freq=$(echo "$existing_data" | jq -r --arg t "$normalized_topic" '.topic_frequencies[$t] // 0')
    local new_freq=$((current_freq + 1))

    # 构建新的 topic_frequencies
    local new_topic_freq=$(echo "$existing_data" | jq --arg t "$normalized_topic" --arg v "$new_freq" \
        '.topic_frequencies[$t] = ($v | tonumber)')

    # 更新 last_active
    new_topic_freq=$(echo "$new_topic_freq" | jq --arg d "$current_date" '.last_active = $d')

    # 更新 created（如果是首次）
    local created=$(echo "$new_topic_freq" | jq -r '.created // empty')
    if [ -z "$created" ]; then
        new_topic_freq=$(echo "$new_topic_freq" | jq --arg d "$current_date" '.created = $d')
    fi

    # 更新最近主题（保留最后 10 个）
    local recent=$(echo "$new_topic_freq" | jq --arg t "$normalized_topic" --arg ts "$current_time" \
        '(.recent_topics = ([{topic: $t, timestamp: ($ts | tonumber)}] + .recent_topics) | unique_by(.topic) | .[0:10])')

    # 增加学习连续天数
    local last_active=$(echo "$recent" | jq -r '.last_active // empty')
    local learning_streak=$(echo "$recent" | jq '.learning_streak // 0')

    # 记录到历史（保留最后 100 条）
    local history_entry="{\"topic\":\"$normalized_topic\",\"difficulty\":$difficulty,\"timestamp\":$current_time,\"date\":\"$current_date\"}"
    local new_history=$(echo "$recent" | jq --argjson e "$history_entry" \
        '(.query_history = ([$e] + .query_history) | .[0:100])')

    # 保存更新
    echo "$new_history" > "$USER_ACTIVITY_FILE"

    # 同时更新 Wiki 页面的 frontmatter
    update_wiki_page_query "$normalized_topic" "$current_date"

    log_info "已记录查询: $normalized_topic (频率: $new_freq, 难度: $difficulty)"
}

# 更新 Wiki 页面的 query_count
update_wiki_page_query() {
    local topic="$1"
    local current_date="$2"

    # 查找匹配的 Wiki 页面
    local page_path=""
    local slug=""

    # 搜索概念页面
    for dir in concepts entities sources synthesis guides tips tutorial; do
        if [ -d "$WIKI_DIR/$dir" ]; then
            local found=$(find "$WIKI_DIR/$dir" -name "*.md" -type f 2>/dev/null | while read f; do
                local name=$(grep "^name:" "$f" | head -1 | sed 's/name: *//' | tr -d ' ')
                if [[ "$name" == *"$topic"* ]] || [[ "$f" == *"$topic"* ]]; then
                    echo "$f"
                    break
                fi
            done)
            if [ -n "$found" ]; then
                page_path="$found"
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
        sed -i "s/^query_count:.*/query_count: $new_count/" "$page_path"
    else
        # 在第一个 --- 之后添加
        sed -i "/^---$/a\\query_count: 1" "$page_path"
    fi

    # 更新 last_queried
    if grep -q "^last_queried:" "$page_path" 2>/dev/null; then
        sed -i "s/^last_queried:.*/last_queried: $current_date/" "$page_path"
    else
        sed -i "/^---$/a\\last_queried: $current_date" "$page_path"
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
    local today=$(get_date)
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
            echo "  learning-tracker.sh init                  # 初始化追踪文件"
            echo "  learning-tracker.sh record <topic> [难度]  # 记录查询事件"
            echo "  learning-tracker.sh analyze                # 分析学习数据"
            echo "  learning-tracker.sh recommend              # 获取推荐"
            echo ""
            echo "示例:"
            echo "  learning-tracker.sh record javascript 3"
            echo "  learning-tracker.sh analyze"
            ;;
    esac
}

main "$@"