---
name: sources/example-source
description: 示例来源文档摘要
type: source
tags: [example, documentation]
created: 2026-04-30
updated: 2026-04-30
source: ../../archive/sources/example-source.md
status: draft
confidence: medium
---

# 示例来源文档

> 本页展示 source 类型页面的标准格式

## 文档信息

| 字段 | 值 |
|------|-----|
| 原始文件 | `archive/sources/example-source.md` |
| 类型 | 来源摘要 |
| 状态 | draft |

## 关键要点

1. **来源类型页面** 用于记录外部文档的摘要信息
2. **source 字段** 指向 archive/ 中的原始不可变文件
3. **status** 通常为 draft，待验证后升为 stable

## 与其他页面的关系

- **提取的概念**: [[concepts/example-concept]]
- **提取的实体**: [[entities/example-entity]]
- **综合分析**: [[synthesis/example-analysis]]

## 使用场景

当使用 `docs-ingest` 摄取新文档时：
1. 创建 `source/` 页面记录来源摘要
2. 从源文档中提取的概念 → `concepts/` 页面
3. 从源文档中提取的实体 → `entities/` 页面
4. 综合分析 → `synthesis/` 页面

## 注意事项

- 源文件归档到 `archive/` 后**不可修改**
- 如有更新需求，应在 Wiki 页面中补充，而非修改归档文件
- 多个来源可以引用同一个 archive 文件
