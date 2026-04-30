---
name: learning-tracker
description: 智能学习进化系统。追踪用户查询行为，自动构建知识画像，识别学习缺口，在适当时机主动推荐相关内容，实现知识复利持续累积。
---

# Learning Tracker — 智能学习进化系统

> 让 Wiki 越用越智能，越用越了解用户

## 概念

Learning Tracker 是 obsidian-wiki 的智能进化引擎，通过追踪用户的查询行为，自动构建知识画像，识别学习缺口，并在适当时机主动提议推荐，实现"知识复利"的持续累积。

## 核心机制

### 双轨数据结构

| 层级 | 存储位置 | 用途 | 更新频率 |
|------|----------|------|----------|
| **轻量层** | `config/user-activity.json` | 快速查询、高频统计 | 每次查询 |
| **Wiki 层** | frontmatter 扩展字段 | 深度分析、关系构建 | 每日/周 |
| **图谱层** | `wiki/synthesis/user-learning/` | 学习路径、推荐生成 | 定期生成 |

### frontmatter 扩展字段

```yaml
---
name: concepts/topic-name
# ... 标准字段 ...
# --- 智能进化字段（可选） ---
query_count: 12          # 被查询次数
last_queried: 2024-03-18 # 最后查询时间
difficulty_level: 3      # 1-5，用户理解难度评分
learning_path: next      # prev/next/core - 学习顺序标记
---
```

## 组件

### 1. tracker.sh

用户学习活动追踪主脚本。

**命令:**
- `init` — 初始化追踪文件
- `record <topic> [difficulty]` — 记录查询事件
- `analyze` — 分析学习数据
- `recommend` — 获取推荐

**记录的事件:**
- topic（规范化主题名）
- frequency（查询次数）
- difficulty（理解难度 1-5）
- timestamp

### 2. analyzer.sh

学习分析器，生成推荐和报告。

**命令:**
- `init` — 初始化学习目录结构
- `update-graph` — 更新知识图谱
- `update-rec` — 更新推荐页面
- `report` — 生成会话总结
- `analyze` — 执行完整分析

### 3. user-activity.json

用户活动数据文件。

**结构:**
```json
{
  "user_id": "default",
  "last_active": "2024-03-18",
  "topic_frequencies": {
    "javascript": 45,
    "typescript": 32
  },
  "weak_areas": [
    {"topic": "async-await", "count": 5, "avg_difficulty": 4.2}
  ],
  "learning_streak": 7,
  "total_queries": 156
}
```

### 4. user-learning/ Wiki 页面

自动生成的 Wiki 页面结构：

```
wiki/synthesis/user-learning/
├── knowledge-graph.md    # 主题关系图谱
└── recommendations.md     # 个性化推荐
```

## 触发机制

| 场景 | 频率策略 | 操作 |
|------|----------|------|
| 用户连续问 3+ 个相关问题 | 立即 | 提议创建该主题概念页 |
| 用户问基础问题（difficulty 1-2） | 中频 | 提议创建基础概念页 |
| 用户完成一个主题讨论 | 低频 | 追加学习路径，推荐下一个 |
| 用户超过 7 天未问某曾问主题 | 遗忘提醒 | 主动提议复习 |

## 与 wiki-query 集成

wiki-query 执行流程：

1. **搜索** — 在 Wiki 中搜索相关页面
2. **补充搜索** — 确保覆盖
3. **读取** — 获取关键页面内容
4. **追踪** — 调用 `tracker.sh record` 记录主题
5. **综合** — 整合答案
6. **引用** — 标注来源
7. **评估写回** — 判断是否写回
8. **推荐** — 检查是否需要推荐

## 安装

通过 `install.sh` / `install.bat` 自动安装：

1. 复制 `tracker.sh` 和 `analyzer.sh`
2. 首次运行 `tracker.sh init` 时自动创建 `config/user-activity.json`

## 文件清单

```
learning-tracker/
├── SKILL.md                    # 本文档
├── tracker.sh                  # 追踪主脚本
├── analyzer.sh                 # 分析器脚本
└── config/
    └── user-activity.json.base # 数据模板

wiki/synthesis/user-learning/   # Wiki 层（自动创建）
├── knowledge-graph.md
└── recommendations.md
```