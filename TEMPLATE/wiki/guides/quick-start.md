---
name: quick-start
description: Wiki 快速开始指南 — 5 分钟上手
type: guide
tags: [guide, beginner, tutorial]
created: 2026-04-26
updated: 2026-04-26
status: stable
confidence: high
source: ../../archive/sources/quick-start.md
---

# Quick Start Guide

快速开始使用 Wiki 知识库。

## 5 分钟上手

### Step 1: 添加文档

将源文档放入 `raw/` 目录：

```bash
# 示例
cp ~/documents/research-notes.md raw/
```

### Step 2: Ingest

使用 skill 摄取文档：

```
使用 docs-ingest skill 摄取 raw/ 中的文档
```

### Step 3: 查询

在 Wiki 中搜索相关知识：

```
使用 wiki-query 搜索相关页面
```

### Step 4: 维护

定期运行健康检查：

```bash
cd wiki && ../scripts/lint.sh
```

## 下一步

- [[wiki-concept]] — 了解 Wiki 概念
- [[wiki-tutorial]] — 深入学习 Wiki 使用

---
*Wiki 快速开始*