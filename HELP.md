# Obsidian Wiki Skill 使用帮助

基于 Karpathy LLM Wiki 理论的多页综合知识引擎，实现知识复利。

## 快速开始

### 1. 初始化 Wiki

```
说: "创建一个新的研究知识库"
或: "使用 obsidian-wiki 初始化"
```

创建完整目录结构：
```
├── .obsidian/           # Obsidian 配置
├── archive/sources/      # 源文件归档
├── raw/notes/           # 待处理文件
├── scripts/             # 工具脚本
└── wiki/               # Wiki 知识库
    ├── WIKI.md         # Schema 规范
    ├── index.md        # 手动索引
    ├── log.md         # 操作日志
    ├── concepts/       # 核心概念
    ├── entities/       # 实体文档
    ├── sources/        # 来源摘要
    ├── synthesis/      # 综合分析
    ├── guides/        # 使用指南
    ├── tips/          # 实用技巧
    └── tutorial/       # 教程
```

### 2. 添加知识

将文档放入 `raw/` 目录：

```bash
# 示例
cp ~/documents/research.md raw/
```

然后说：
```
说: "使用 docs-ingest 摄取这个文档"
```

### 3. 查询知识

```
说: "使用 wiki-query 搜索关于 XXX 的知识"
说: "查询 YYY 概念"
```

遵循 **Wiki-First 原则**：永远先搜索 Wiki，再生成答案。

### 4. 健康检查

```bash
cd wiki && ../scripts/wiki-lint.sh
```

检查内容：
- Frontmatter 完整性
- 交叉引用有效性
- Source 路径正确性
- 孤立页面
- 知识矛盾

### 5. 会话捕获

```
说: "使用 wiki-capture 记录这个经验"
说: "保存到知识库"
```

---

## 五大组件

| Skill | 触发场景 | 核心能力 |
|-------|----------|----------|
| `obsidian-wiki` | 创建/初始化 Wiki | 完整结构搭建 |
| `docs-ingest` | 摄取文档、整理资料 | 1:N 多页综合摄取 |
| `wiki-query` | 查询、解释、搜索 | Wiki-First + 答案写回 |
| `wiki-lint` | 健康检查、维护 | 矛盾/孤立检测 |
| `wiki-capture` | 记录经验、沉淀知识 | 会话内容捕获 |

---

## Frontmatter 标准

```yaml
---
name: category/slug        # 页面 slug (必需)
description: 一句话描述     # (必需)
type: concept | entity | source | synthesis | guide | tips | tutorial
tags: [tag1, tag2]
created: YYYY-MM-DD        # (必需)
updated: YYYY-MM-DD        # (必需)
status: draft | stable | challenged | superseded
confidence: low | medium | high
source: ../../archive/sources/filename.md
---
```

### 页面类型

| 类型 | 用途 | 示例 |
|------|------|------|
| `concept` | 核心概念定义 | "LLM Wiki 方法论" |
| `entity` | 实体文档记录 | "项目 X 技术栈" |
| `source` | 来源摘要 | "论文 Y 要点" |
| `synthesis` | 综合分析 | "技术选型对比" |
| `guide` | 使用指南 | "快速上手指南" |
| `tips` | 实用技巧 | "维护技巧" |
| `tutorial` | 教程 | "完整教程" |

### Status 生命周期

```
draft → stable → (challenged → stable | superseded)
```

| 状态 | 说明 |
|------|------|
| `draft` | 新创建，未充分验证 |
| `stable` | 经过验证的可靠知识 |
| `challenged` | 新证据提出质疑，待确认 |
| `superseded` | 已被更新的页面取代 |

---

## docs-ingest 流程 (1:N 多页摄取)

### Phase 1: 解析
读取源文件，提取：
- 概念（术语、定义、原理）
- 实体（人、组织、项目、工具）
- 关系（A 依赖 B）
- 声明（有来源的结论）
- 元数据（日期、来源）

### Phase 2: 映射
搜索 Wiki，对每个概念/实体判断：
- **新增** → 创建新页面
- **更新** → 补充已有页面
- **矛盾** → 标记并讨论

输出摄取计划给用户确认：
```
📋 摄取计划（来源: article.md）

新增页面:
  - concepts/new-concept — 概念定义
  - entities/new-entity — 实体记录

更新页面:
  - concepts/existing — 补充 X 方面信息

⚠️ 矛盾检测:
  - concepts/existing → 新数据与旧声明冲突

是否继续？
```

### Phase 3: 综合
- 创建/更新页面
- 添加 `[[wikilink]]` 交叉引用
- 标记矛盾 (warning callout)
- 更新 frontmatter

### Phase 4: 索引
- 更新 index.md
- 追加 log.md

### Phase 5: 归档
```bash
mv raw/filename.md archive/sources/filename.md
```

---

## wiki-query 流程 (知识复利引擎)

### Wiki-First 原则

永远先搜索 Wiki，再生成答案。

### 执行步骤

1. **搜索**: `obsidian search query="关键词"`
2. **补充搜索**: 用不同关键词再搜一次
3. **读取**: 获取关键页面内容
4. **综合**: 整合多个页面回答
5. **引用**: 标注 `[[来源页面]]`
6. **评估写回**: 判断是否值得创建 synthesis 页面

### 答案写回标准

| 答案类型 | 是否写回 | 目标 |
|----------|----------|------|
| 综合 3+ 个页面 | 是 | synthesis/ 新页面 |
| 对比多个方案 | 是 | synthesis/ 新页面 |
| 发现新概念关联 | 是 | 更新相关页面 |
| 简单解释 | 否 | 直接回答 |

---

## wiki-lint 检查项目

```bash
cd wiki && ../scripts/wiki-lint.sh
```

生成 `wiki/WIKI-LINT-REPORT.md` 报告，包含：

| 检查项 | 说明 |
|--------|------|
| 页面统计 | 各目录文件数量 |
| Frontmatter 检查 | name/description/type 完整性 |
| 链接健康 | `[[wikilinks]]` 目标是否存在 |
| 孤立页面 | 无入站链接的页面 |
| 矛盾检测 | `status: challenged` 和 `> [!warning]` |
| Source 路径 | source 字段指向文件是否存在 |

---

## wiki-capture 笔记模板

```markdown
---
name: notes/YYYY-MM-DD-{topic}
description: 一句话描述
type: insight | pattern | tip | lesson
tags: [session, relevant-tags]
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

---

## 目录用途

| 目录 | 用途 | 说明 |
|------|------|------|
| `raw/` | 待处理文件 | 摄入前临时存放 |
| `raw/notes/` | 会话捕获 | wiki-capture 输出 |
| `archive/` | 归档存储 | 源文件不可变存储 |
| `wiki/` | Wiki 知识库 | LLM 拥有的知识 |

---

## 典型工作流

### L1: 个人笔记
```
添加文档 → raw/ → docs-ingest → wiki/ → archive/
```

### L2: 研究项目
```
批量摄取 → 矛盾检测 → wiki-query → synthesis 写回
```

### L3: 专业知识库
```
+ defuddle 网页摄取
+ Bases 动态视图
+ Canvas 知识图
```

---

## 常见问题

| 问题 | 解决 |
|------|------|
| 链接失效 | 运行 wiki-lint 检查 |
| 孤立页面 | 添加相关 `[[wikilink]]` |
| 知识矛盾 | 添加 `> [!warning]` callout |
| 源文件丢失 | 检查 archive/sources/ 路径 |

---

## 相关资源

- [WIKI.md](wiki/WIKI.md) — 完整 Schema 规范
- [docs-ingest](../docs-ingest/SKILL.md) — 多页摄取技能
- [wiki-query](../wiki-query/SKILL.md) — 查询写回技能
- [wiki-lint](../wiki-lint/SKILL.md) — 健康检查技能
- [wiki-capture](../wiki-capture/SKILL.md) — 会话捕获技能

---

*基于 Andrej Karpathy LLM Wiki 理论构建*
