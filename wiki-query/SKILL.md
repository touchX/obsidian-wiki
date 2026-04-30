---
name: wiki-query
description: Wiki 知识查询与知识复利技能。当用户询问任何 Wiki 中可能已有答案的问题时必须使用，包括概念解释、命令用法、配置选项、最佳实践。先查 Wiki 再回答，避免重复生成摘要。综合性答案应提议写回 Wiki 成为新页面。
---

# Wiki 查询技能（知识复利引擎）

基于 Wiki 回答问题，遵循 Wiki-First 原则。优质答案写回 Wiki，实现知识复利。

## 触发条件

- 用户询问功能、概念、最佳实践
- 需要查找命令用法、配置选项
- 任何需要准确信息的问题
- 用户要求比较、分析或综合多个主题

## Wiki-First 原则

**核心规则：** 永远先查询 Wiki，再生成答案。优先引用现有页面，使用 `[[wikilink]]` 标注来源。

## 执行步骤

1. **搜索**: 在 Wiki 中搜索相关页面
2. **补充搜索**: 用不同关键词再搜一次，确保覆盖
3. **读取**: 获取关键页面详细内容
4. **综合**: 整合多个页面答案回答问题
5. **引用**: 标注来源页面链接 `[[page-slug]]`
6. **评估写回**: 判断答案是否值得写回 Wiki

## 搜索方法

**优先使用 obsidian-cli**:
```bash
obsidian search query="关键词" limit=10
obsidian read file="PageName"
obsidian tags sort=count counts
obsidian backlinks file="some-note"
```

**降级方案**:
```bash
grep -r "关键词" wiki/ --include="*.md" -l
```

## 无结果时的降级策略

如果 Wiki 为空或搜索无结果，按以下顺序降级：

1. **搜索 raw/ 目录**: `grep -r "关键词" raw/ --include="*.md" -l`
2. **搜索 archive/ 目录**: `grep -r "关键词" archive/ --include="*.md" -l`
3. **使用 WebSearch**: 作为最后手段，结合网络搜索回答
4. **建议创建首个页面**: 如果 Wiki 完全是空的，向用户提议创建第一个概念页面

> 注意：Wiki-First 原则意味着每次回答都应该让 Wiki 更丰富。即使是简单的概念解释，也建议在回答后提议创建一个基础的 `concept/` 页面。

## 知识复利：答案写回

这是区别于普通 RAG 的核心机制——好的答案不应消失在对话历史中。

### 写回判断标准

| 答案类型 | 是否写回 | 目标位置 |
|----------|----------|----------|
| 综合了 3+ 个页面的分析 | 是 | `synthesis/` 新页面 |
| 对比了多个方案/工具 | 是 | `synthesis/` 新页面 |
| 发现了新的概念关联 | 是 | 更新相关页面添加 `[[链接]]` |
| 简单概念解释 | 否 | 直接回答 |
| 已有页面的重复 | 否 | 直接引用 |

### 写回流程

1. 回答用户问题
2. 如果符合写回标准，向用户提议：
   ```
   💡 这次回答综合了多个 Wiki 页面的信息。
   建议: 创建 synthesis/topic-comparison.md
   内容: [简要描述]
   是否写入？
   ```
3. 用户确认后创建页面（标准 frontmatter）
4. 更新相关已有页面的交叉引用
5. 追加 log.md 条目

### 写回页面模板

```markdown
---
name: synthesis/topic-analysis
description: 一句话描述分析结论
type: synthesis
tags: [analysis, relevant-tags]
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - "[[source-page-1]]"
  - "[[source-page-2]]"
status: stable
confidence: high
---

# Topic Analysis

> 综合自: [[source-1]], [[source-2]], [[source-3]]

## 结论
[核心发现]

## 分析过程
[详细分析]

## 相关页面
- [[concept-a]] — 相关概念
- [[entity-b]] — 相关实体
```

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 直接生成摘要 | 先搜索 Wiki |
| 只用一个关键词 | 语义+关键词双重搜索 |
| 不引用来源 | 标注 `[[page-slug]]` 链接 |
| 好答案消失在对话中 | 评估写回，提议创建新页面 |
