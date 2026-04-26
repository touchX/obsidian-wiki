---
name: wiki-architecture
description: Wiki 架构综合分析 — 三层架构设计思路
type: synthesis
tags: [architecture, design, wiki]
created: 2026-04-26
updated: 2026-04-26
source: ../../archive/synthesis/wiki-architecture.md
---

# Wiki Architecture Synthesis

综合分析 Wiki 的架构设计。

## 三层架构

```
[源文件] → raw/ → [ingest] → wiki/ + [归档] → archive/
```

| 层级 | 目录 | 职责 |
|------|------|------|
| 输入层 | `raw/` | 临时存放待处理文件 |
| 处理层 | `wiki/` | 知识库主体 |
| 归档层 | `archive/` | 已处理文件归档 |

## 设计原则

1. **分层清晰** — 输入、处理、归档分离
2. **原子化存储** — 每页一个概念
3. **双向引用** — Wiki 页面引用原始文件
4. **可维护性** — 通过 lint 脚本保证健康

## 实现要点

- Frontmatter 标准化
- Wiki 链接 `[[page]]` 互相引用
- 操作日志跟踪变更
- 健康检查自动化

## 相关页面

- [[wiki-concept]] — 核心概念
- [[quick-start]] — 快速开始

---
*Wiki 架构综合分析*