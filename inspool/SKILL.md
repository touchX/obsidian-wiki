---
name: wiki-capture
description: 会话知识捕获技能（原 inspool）。当完成复杂解答、发现新模式、积累实用技巧、会话即将结束时，将高价值内容捕获到 raw/notes/ 供后续摄取。用户说"记录一下"、"保存经验"、"沉淀知识"、"capture"时也应触发。
---

# 会话知识捕获技能

将高价值回答、阶段性结果、经验教训捕获到 `raw/notes/`，供 docs-ingest 多页综合摄取。

## 触发条件

- 完成复杂问题解答
- 发现新的通用模式
- 积累实用技巧或经验教训
- 会话结束前的知识沉淀
- 用户主动要求记录

## 是否应该捕获？

| 判断条件 | 决策 |
|----------|------|
| 解决方案复杂度 > 5 分钟 | 捕获 |
| 发现通用模式 | 捕获 |
| 错误教训值得分享 | 捕获 |
| 综合了多个 Wiki 页面 | 捕获 |
| 纯执行无新知 | 不捕获 |
| 已知信息确认 | 不捕获 |

## 执行步骤

1. **识别**: 从对话中识别高价值内容
2. **提炼**: 提取关键信息，去除噪音
3. **关联**: 检查 `[[已有 Wiki 页面]]` 避免重复
4. **写入**: 创建笔记到 `raw/notes/YYYY-MM-DD-{topic}.md`
5. **提议摄取**: 如果笔记足够丰富，提议立即运行 docs-ingest

## 笔记模板

```markdown
---
name: notes/YYYY-MM-DD-{topic}
description: 一句话描述
type: tips
tags: [session, insight, {relevant-tags}]
created: {date}
source: conversation
related:
  - "[[existing-wiki-page]]"
---

# {Topic}

## 关键发现
- 要点 1
- 要点 2

## 上下文
{相关背景}

## 应用场景
{何时使用}

## 相关 Wiki 页面
- [[existing-page]]
```

## 与 Daily Note 集成

如果项目启用了 Obsidian daily notes：

```bash
# 追加摘要到当日笔记
obsidian daily:append content="- 📝 捕获: [[notes/topic]] — 一句话描述"
```

## 笔记标签

捕获的笔记建议使用以下标签分类：

| 标签 | 用途 | 示例 |
|------|------|------|
| `insight` | 新发现 | 突破性认知 |
| `pattern` | 通用模式 | 可复用方法 |
| `lesson` | 经验教训 | 失败教训 |

> 注意：type 统一使用 `tips`，通过 tags 区分具体类型。

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 会话结束不捕获 | 会话结束前主动运行 wiki-capture |
| 记录太笼统 | 具体：问题→解决→结果 |
| 不关联已有 Wiki | 检查 `[[links]]` 避免重复 |
| 捕获后不摄取 | 对丰富笔记提议运行 docs-ingest |
