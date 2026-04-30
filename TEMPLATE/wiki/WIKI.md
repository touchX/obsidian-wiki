---
name: wiki-schema
description: Wiki 架构规范 — 目录结构、操作流程和约定
type: guide
version: 2.0
---

# Wiki Schema

本文档定义了 Wiki 的架构、规范和工作流程。

## 架构概览

```
[源文件] → raw/ → [docs-ingest] → wiki/ + [源文件] → archive/
```

| 阶段 | 目录 | 说明 |
|------|------|------|
| 摄入前 | `raw/` | 临时存放待处理源文件 |
| 处理中 | `wiki/` | Wiki 知识库（LLM 拥有） |
| 处理后 | `archive/` | 源文件归档（不可变） |

## 目录结构

```
project-root/
├── raw/                    # ingest 前临时目录
│   └── notes/             # 会话捕获笔记
├── wiki/                   # Wiki 知识库
│   ├── WIKI.md            # 本文件（schema 规范）
│   ├── wiki-index.base    # Bases 动态索引视图
│   ├── index.md           # Wiki 目录（手动或Bases生成）
│   ├── log.md             # 操作日志（append-only）
│   ├── concepts/          # 概念
│   ├── entities/          # 实体
│   ├── sources/           # 来源摘要
│   ├── synthesis/         # 综合分析
│   ├── guides/            # 使用指南
│   ├── tips/              # 技巧总结
│   └── tutorial/          # 教程
├── archive/               # 归档目录
│   ├── assets/            # 图片、音频、视频等素材
│   └── sources/           # 源文件归档（来自 raw/）
```

## 核心原则

**Karpathy LLM Wiki 理论：** Wiki 是持久增长的复利资产。每次摄入都让整个知识库更丰富，而非简单的文件翻译。

- LLM 拥有 wiki/ 层（读写）
- LLM 只读 raw/ 和 archive/ 层（永不修改）
- 好的答案应写回 Wiki（知识复利机制）

## Obsidian 插件

本项目预配置以下插件（位于 `.obsidian/plugins/`）：

| 插件 | 用途 | 说明 |
|------|------|------|
| **dataview** | 数据查询 | 用于 index.md 自动生成页面目录 |
| **calendar** | 日历视图 | 按日期浏览 log.md 操作日志 |
| **claudian** | Claude 集成 | 与 Claude Code CLI 交互 |
| **obsidian-bases** | 动态视图 | .base 文件生成表格/卡片视图（推荐） |
| **omnisearch** | 统一搜索 | 图片 OCR、音视频搜索 |
| **obsidian-excalidraw-plugin** | 画布绘图 | Excalidraw 集成 |
| **templater-obsidian** | 模板引擎 | 高级动态模板 |
| **tag-wrangler** | 标签管理 | 批量重命名、合并标签 |
| **file-explorer-note-count** | 目录计数 | 文件浏览器显示笔记数量 |
| **obsidian-custom-attachment-location** | 附件管理 | 自定义附件存储位置 |
| **obsidian-local-rest-api** | REST API | 本地 HTTP API 集成 |
| **recent-files-obsidian** | 最近文件 | 快速访问最近文件 |

### Bases 动态索引

`wiki/wiki-index.base` 提供 4 个动态视图：

| 视图 | 用途 |
|------|------|
| 按类型浏览 | 按 type 分组表格 |
| 最近更新 | 最近 20 个页面 |
| 需要关注 | challenged/draft 状态页面 |
| 知识卡片 | 卡片式浏览 |

## 页面格式

### Frontmatter（必须）

```markdown
---
name: page-slug
description: 一句话描述
type: concept | entity | source | synthesis | guide | tutorial | tips
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: ../../archive/sources/filename.md
status: draft | stable | challenged | superseded
confidence: low | medium | high
contradicts: [[page-slug]]
superseded_by: [[page-slug]]
sources: [[page-1]], [[page-2]]
---
```

### 必需字段

| 字段 | 说明 |
|------|------|
| `name` | 页面 slug |
| `description` | 一句话描述 |
| `type` | 页面类型 |
| `tags` | 标签数组 |
| `created` | 创建日期 |
| `updated` | 更新日期 |

### 建议字段

| 字段 | 说明 |
|------|------|
| `source` | 原始文件路径（指向 archive/） |
| `status` | 知识状态（默认 draft） |
| `confidence` | 置信度（默认 medium） |
| `contradicts` | 与之矛盾的页面 |
| `superseded_by` | 取代本文的页面 |
| `sources` | 知识来源页面列表 |

### Type 类型

| Type | 用途 |
|------|------|
| `concept` | 核心概念 |
| `entity` | 实体文档 |
| `source` | 来源摘要 |
| `synthesis` | 综合分析 |
| `guide` | 使用指南 |
| `tutorial` | 教程 |
| `tips` | 实用技巧 |

### Status 生命周期

```
draft → stable → (challenged → stable | superseded)
```

| Status | 说明 |
|--------|------|
| `draft` | 新创建，未充分验证 |
| `stable` | 经过验证的可靠知识 |
| `challenged` | 新证据提出质疑，待确认 |
| `superseded` | 已被更新的页面取代 |

## 操作流程

### Ingest（摄入）

```bash
# 使用 docs-ingest skill
# 支持: 文件(raw/)、URL(defuddle 提取)、批量
```

### Query（查询）

```bash
# 使用 wiki-query skill
# Wiki-First 原则：先搜索再回答
# 优质答案自动提议写回为 synthesis 页面
```

### Lint（检查）

使用 wiki-lint skill 进行健康检查：

```
说: "使用 wiki-lint"
```

---