# Obsidian Wiki Skill

> 基于 Karpathy LLM Wiki 理论的知识复利引擎 — 让每次问答都使知识库更丰富

[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 核心理念

**Wiki 是持久增长的复利资产。** 不同于传统 RAG 的"每次查询从零检索"，LLM Wiki 在每次摄入和问答时都**更新和维护 Wiki 本身**——交叉引用已建立、矛盾已标记、综合分析已形成。知识随时间积累，而非重复消耗。

```
传统 RAG: 文档 → 查询 → 答案 (知识丢失)
LLM Wiki:  文档 → 摄入 → Wiki 丰富 → 查询 → 答案 (知识累积)
```

## 快速开始

### 1. 安装依赖

```bash
# 安装 obsidian-cli
npm install -g @obsidianmd/obsidian-utilities-cli

# 安装 obsidian-skills (Obsidian 插件)
# 设置 → 社区插件 → 搜索 "obsidian-skills"
```

### 2. 初始化 Wiki

```bash
# 复制模板到目标目录
cp -r TEMPLATE my-wiki/
cd my-wiki

# 或使用 Claude Code
# 说: "使用 obsidian-wiki 初始化"
```

### 3. 添加知识

```
1. 将文档放入 raw/ 目录
2. 说: "使用 docs-ingest 摄取"
3. 自动创建/更新多个 Wiki 页面
```

### 4. 查询知识

```
说: "使用 wiki-query 查询关于 XXX"
优质答案会自动提议写回为 synthesis 页面
```

## 核心功能

| 技能 | 触发 | 能力 |
|------|--------|------|
| `docs-ingest` | 摄取文档、整理资料 | 1:N 多页综合摄取，矛盾检测 |
| `wiki-query` | 搜索、解释、比较 | Wiki-First 原则 + 答案写回 |
| `wiki-lint` | 健康检查、维护 | 孤立页面、矛盾、知识缺口检测 |
| `wiki-capture` | 记录经验、沉淀知识 | 会话高价值内容捕获 |
| `learning-tracker` | 学习追踪、智能推荐 | 主题频率、缺口分析、个性化推荐 |

## 工作流

```
                    ┌─────────────────────────────────────┐
                    │           raw/ (摄入前)              │
                    │   源文档、网页剪藏、会话笔记           │
                    └──────────────┬──────────────────────┘
                                   │ docs-ingest
                                   ▼
┌──────────────┐    ┌─────────────────────────────────────┐
│ archive/     │◄───│         wiki/ (LLM 拥有)             │
│ (不可变归档)  │    │  concepts/ entities/ synthesis/     │
└──────────────┘    │  sources/ guides/ tips/ tutorial/    │
                    └──────────────┬──────────────────────┘
                                   │ wiki-query
                                   ▼
                          ┌─────────────────┐
                          │   知识复利       │
                          │ 答案写回 synthesis/
                          └─────────────────┘
```

## 目录结构

```
my-wiki/
├── .obsidian/              # Obsidian 配置 + 12 个预配置插件
├── raw/                    # 待处理文件
│   └── notes/            # 会话捕获笔记
├── archive/               # 源文件归档 (不可变)
│   └── sources/
├── scripts/               # 工具脚本
│   └── lint.sh           # 健康检查
└── wiki/                  # Wiki 知识库
    ├── WIKI.md           # Schema 规范
    ├── wiki-index.base   # Bases 动态索引
    ├── index.md          # 手动索引
    ├── log.md            # 操作日志
    ├── concepts/         # 核心概念
    ├── entities/         # 实体文档
    ├── synthesis/        # 综合分析 ← 答案写回目标
    ├── sources/          # 来源摘要
    ├── guides/          # 使用指南
    ├── tips/            # 实用技巧
    └── tutorial/        # 教程
```

## Frontmatter 标准

```yaml
---
name: page-slug                    # 页面 slug
description: 一句话描述             # 必需
type: concept|entity|source|...   # 7 种类型
tags: [tag1, tag2]                # 标签
created: YYYY-MM-DD                # 创建日期
updated: YYYY-MM-DD                # 更新日期
status: draft|stable|challenged|superseded  # 知识状态
confidence: high|medium|low
source: ../../archive/sources/...  # 原始来源
---
```

### 页面类型

| 类型 | 用途 | 示例 |
|------|------|------|
| `concept` | 核心概念 | "Wiki 知识库方法论" |
| `entity` | 实体文档 | "项目 X 技术栈" |
| `source` | 来源摘要 | "论文 Y 要点" |
| `synthesis` | 综合分析 | "技术选型对比" |
| `guide` | 使用指南 | "快速上手指南" |
| `tips` | 实用技巧 | "维护技巧" |
| `tutorial` | 教程 | "完整教程" |

### 知识状态生命周期

```
draft → stable → (challenged → stable | superseded)
```

## 预配置插件

| 插件 | 用途 |
|------|------|
| **dataview** | 数据查询，自动维护索引 |
| **calendar** | 日历视图，按日期浏览日志 |
| **claudian** | Claude Code 集成 |
| **omnisearch** | 统一搜索 (含图片 OCR) |
| **obsidian-excalidraw-plugin** | Excalidraw 画布 |
| **templater-obsidian** | 高级模板引擎 |
| **obsidian-local-rest-api** | 本地 HTTP API |
| + 5 更多... | 完整列表见 [WIKI.md](TEMPLATE/wiki/WIKI.md) |

## 健康检查

```bash
cd wiki && ../scripts/lint.sh
```

检查内容:
- Frontmatter 完整性
- 交叉引用有效性
- 孤立页面检测
- 知识矛盾标记
- Source 路径正确性

## 相关资源

- [Wiki Schema 规范](TEMPLATE/wiki/WIKI.md) — 完整架构说明
- [LLM Wiki 理论](llm-wiki.md) — Karpathy 核心理论
- [HELP.md](HELP.md) — 快速参考
- [CHANGELOG.md](CHANGELOG.md) — 版本历史

---

*基于 Andrej Karpathy LLM Wiki 理论构建*
