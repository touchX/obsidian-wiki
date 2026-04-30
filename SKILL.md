---
name: obsidian-wiki
description: 独立的 Wiki 知识库系统 — 基于 Karpathy LLM Wiki 理论的多页综合知识引擎。支持创建、多页摄取、查询写回、矛盾检测、健康检查全流程。当用户提到 wiki、知识库、知识管理、笔记系统、文档归档、obsidian、文档体系化、整理文档、建立知识体系、知识复利时必须使用。即使用户只说"整理这些资料"或"建个知识库"，也应触发本技能。
---

# Obsidian Wiki Skill

基于 Andrej Karpathy LLM Wiki 理论的一站式 Wiki 知识库系统。核心理念：**Wiki 是持久增长的复利资产**——每次摄取都让整个知识库更丰富，而非简单的文件翻译。

## 前置要求

| 依赖 | 安装方式 | 说明 |
|------|----------|------|
| obsidian-cli | `npm i -g @obsidianmd/obsidian-utilities-cli` | 页面读写、搜索、daily note |
| obsidian-skills | [GitHub](https://github.com/kepano/obsidian-skills) | CLI + Markdown + Bases + Canvas + Defuddle |

### 验证安装

```bash
obsidian --version          # CLI 工具
npm ls -g defuddle          # 网页提取
```

## 组件概览

| Skill | 用途 | 核心能力 |
|-------|------|----------|
| `obsidian-wiki/init` | 初始化 Wiki | 创建完整目录结构和配置 |
| `docs-ingest` | 多页综合摄取 | 1 源文件 → N 页面，矛盾检测 |
| `wiki-query` | 知识复利查询 | Wiki-First + 答案写回 |
| `wiki-lint` | 健康与演化检查 | 矛盾/孤立/缺口检测 |
| `wiki-capture` | 会话知识捕获 | 高价值内容沉淀 |

## 渐进式复杂度

Karpathy："everything is optional and modular — pick what's useful, ignore what isn't."

| 级别 | 功能 | 适合场景 |
|------|------|----------|
| **L1** | raw→wiki→archive 基础流程 | 个人笔记、读书笔记 |
| **L2** | + 跨页综合、矛盾检测、query 写回 | 研究项目、深度学习 |
| **L3** | + Bases 视图、Canvas 知识图、defuddle 网页摄取 | 专业知识库 |
| **L4** | + 多 Vault、团队协作、搜索引擎(qmd) | 团队 Wiki |

默认启用 L1-L2，L3-L4 按需激活。

## 分层架构

```
obsidian-skills (底层 — 组合使用，不重写)
├── obsidian-cli        → 页面读写、搜索、daily notes
├── obsidian-markdown   → OFM 规范（callouts, embeds, wikilinks）
├── obsidian-bases      → .base 动态视图
├── json-canvas         → .canvas 知识图
└── defuddle            → 网页→markdown 提取
        ↓
Wiki skills (编排层 — 知识复利引擎)
├── docs-ingest         → 1:N 多页综合摄取
├── wiki-query          → 查询 + 答案写回
├── wiki-lint           → 健康检查 + 知识演化
└── wiki-capture        → 会话知识捕获
```

## 使用流程

### Step 1: 初始化
```
使用 Skill: superpowers:obsidian-wiki-init
或: "创建一个新的研究知识库"
```

### Step 2: 摄取知识（1:N 多页综合）
```
使用 docs-ingest skill
支持: 文件(raw/)、URL(defuddle 提取)、批量
```

### Step 3: 查询知识（答案可写回）
```
使用 wiki-query skill
优质答案自动提议写回为新的 synthesis 页面
```

### Step 4: 健康检查（含矛盾检测）
```
使用 wiki-lint skill
检查: frontmatter + 链接 + 矛盾 + 孤立页 + 知识缺口
```

### Step 5: 会话捕获
```
使用 wiki-capture skill
会话结束前捕获高价值内容
```

## 目录结构

```
{WIKI_PATH}/
├── .obsidian/          # Obsidian 配置
├── archive/            # 归档目录
│   ├── assets/         # 图片、音频、视频等素材
│   └── sources/        # 源文件归档
├── raw/                # 临时待处理文件
│   └── notes/          # 会话捕获笔记
├── scripts/            # 工具脚本
│   └── wiki-lint.sh    # 健康检查
└── wiki/               # Wiki 知识库
    ├── WIKI.md         # Schema 规范
    ├── wiki-index.base # Bases 动态索引视图
    ├── index.md        # 手动/Wiki 索引
    ├── log.md          # 操作日志（append-only）
    ├── concepts/       # 核心概念
    ├── entities/       # 实体文档
    ├── guides/         # 使用指南
    ├── sources/        # 来源摘要
    ├── synthesis/      # 综合分析（query 写回目标）
    ├── tips/           # 实用技巧
    └── tutorial/       # 教程
```

## Frontmatter 标准

```yaml
---
name: {category}/{slug}
description: 一句话描述
type: concept | entity | source | synthesis | guide | tutorial | tips
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: ../../archive/sources/filename.md
status: draft | stable | challenged | superseded
confidence: low | medium | high
---
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `name` | ✅ | 页面 slug |
| `description` | ✅ | 一句话描述 |
| `type` | ✅ | 页面类型 |
| `tags` | ✅ | 标签数组 |
| `created` | ✅ | 创建日期 |
| `updated` | ✅ | 更新日期 |
| `source` | 建议 | 原始文件路径 |
| `status` | 建议 | 知识状态（默认 `draft`） |
| `confidence` | 建议 | 置信度（默认 `medium`） |

### Status 生命周期

```
draft → stable → (challenged → stable | superseded)
```

## 三层架构

```
raw/ → [docs-ingest: 1:N] → wiki/ + archive/
```

| 阶段 | 目录 | 说明 |
|------|------|------|
| 摄入前 | `raw/` | 临时存放待处理源文件 |
| 处理中 | `wiki/` | Wiki 知识库（LLM 拥有） |
| 处理后 | `archive/` | 源文件归档（不可变） |

## 执行指令

### 当用户请求初始化 Wiki

1. 提取目标路径
2. 验证路径
3. 复制 TEMPLATE/ 到目标
4. 替换模板占位符（`{{WIKI_NAME}}`, `{{DATE}}`）
5. 创建必需目录（raw/, archive/, raw/notes/）
6. 复制 skills 到 `.claude/skills/`
7. 显示完成信息

## 安装到项目

```bash
# Windows
cd TEMPLATE/scripts && install.bat

# Unix/Linux/Mac
cd TEMPLATE/scripts && chmod +x install.sh && ./install.sh
```

---

*基于 Andrej Karpathy LLM Wiki 理论构建*
