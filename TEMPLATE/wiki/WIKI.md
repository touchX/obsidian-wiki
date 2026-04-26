---
name: wiki-schema
description: Wiki 架构规范 — 目录结构、操作流程和约定
type: guide
version: 1.0
---

# Wiki Schema

本文档定义了 Wiki 的架构、规范和工作流程。

## 架构概览

```
[源文件] → raw/ → [ingest] → wiki/ + [源文件] → archive/
```

| 阶段 | 目录 | 说明 |
|------|------|------|
| 摄入前 | `raw/` | 临时存放待处理源文件 |
| 处理中 | `wiki/` | Wiki 知识库 |
| 处理后 | `archive/` | 源文件归档 |

## 目录结构

```
project-root/
├── raw/                    # ingest 前临时目录
├── wiki/                   # Wiki 知识库
│   ├── WIKI.md            # 本文件
│   ├── index.md           # Wiki 目录
│   ├── log.md             # 操作日志
│   ├── concepts/          # 概念
│   ├── entities/          # 实体
│   ├── sources/           # 来源摘要
│   ├── synthesis/         # 综合分析
│   ├── guides/            # 使用指南
│   ├── tips/              # 技巧总结
│   └── tutorial/          # 教程
├── archive/               # 归档目录
└── scripts/               # 工具
    └── wiki-lint.sh       # 健康检查
```

## 页面格式

### Frontmatter（必须）

```markdown
---
name: page-slug
description: 一句话描述
type: concept | entity | source | synthesis | guide
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: ../../archive/{category}/filename.md
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

### Type 类型

| Type | 用途 |
|------|------|
| `concept` | 核心概念 |
| `entity` | 实体文档 |
| `source` | 来源摘要 |
| `synthesis` | 综合分析 |
| `guide` | 使用指南 |

## 操作流程

### Ingest（摄入）

1. 将文档放入 `raw/` 目录
2. 使用 docs-ingest skill 摄取
3. 文档自动归档到 `archive/`

### Query（查询）

1. 读取 `wiki/index.md` 找相关页面
2. 阅读相关页面获取背景
3. 综合回答

### Lint（检查）

```bash
cd wiki && ../scripts/wiki-lint.sh
```

## 工具

- `scripts/wiki-lint.sh` — Wiki 健康检查

---

*基于 Claude Code Best Practice Wiki 方法论构建*
