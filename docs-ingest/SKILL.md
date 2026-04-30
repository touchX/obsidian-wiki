---
name: docs-ingest
description: 多页综合摄取引擎。当用户提到摄取文档、导入资料、处理 raw 目录文件、将文档加入知识库、整理资料到 wiki、导入网页、处理 URL 时必须使用。发现 raw/ 目录有新文件时也应主动触发。核心能力：1 个源文件 → N 个 wiki 页面的知识综合。
---

# 文档摄取技能（多页综合引擎）

将源文档分解为知识原子，综合到 Wiki 的多个页面中，实现 Karpathy 的"知识复利"——每次摄取都让整个 Wiki 更丰富。

## 多格式文档支持

docs-ingest 现在支持多种文档格式的摄入：

| 格式类别 | 支持格式 | 处理方式 |
|---------|---------|---------|
| **PDF** | .pdf | pdf skill |
| **Word** | .docx, .doc | docx skill (.doc 自动转换为 .docx) |
| **Excel** | .xlsx, .xls | xlsx skill (.xls 自动转换为 .xlsx) |
| **Markdown** | .md, .markdown | 内置处理 |
| **网页** | .html, .htm | defuddle |
| **纯文本** | .txt | 内置处理 |

### 处理流程

1. **MIME 检测** — 自动识别文件格式
2. **预转换** — 旧格式自动转换为现代格式
3. **Skill 路由** — 根据格式调用对应处理 skill
4. **Wiki 生成** — 生成带 format 字段的 Wiki 页面
5. **文件归档** — 原始文件归档到 archive/sources/

## 核心理念

一次摄取不仅仅是"翻译"一个文件，而是：
- 识别源文件中的**所有概念、实体、关系**
- **更新已有页面**（补充新信息、修正过时信息）
- **创建新页面**（新发现的实体/概念）
- **标记矛盾**（新数据与旧结论冲突时）
- **强化交叉引用**（发现新的 `[[链接]]` 关系）
- **更新索引和日志**

一个源文件可能影响 10-15 个 Wiki 页面。

## 触发条件

- 发现新文档在 `raw/` 目录
- 用户要求摄取外部文档到 Wiki
- 用户提供 URL（配合 defuddle 提取）
- 需要将现有知识体系化

## 执行步骤

### Phase 1: 解析（Analyze）

1. 读取 `raw/` 中的源文件
2. 提取知识结构：
   - **概念**（术语、定义、原理）
   - **实体**（人、组织、项目、工具）
   - **关系**（A 依赖 B、X 是 Y 的子集）
   - **声明**（有来源支撑的结论）
   - **元数据**（日期、来源、可靠性）
3. 与用户讨论关键发现，确认重点

### Phase 2: 映射（Map）

将提取的知识映射到 Wiki 现有结构：

1. **搜索现有页面** — 对每个概念/实体搜索 Wiki
   ```
   优先: obsidian search query="关键词" limit=5
   降级: grep -r "关键词" wiki/ --include="*.md" -l
   ```

2. **分类为三种操作**：
   | 类型 | 动作 | 说明 |
   |------|------|------|
   | **新增** | 创建新页面 | Wiki 中不存在此概念/实体 |
   | **更新** | 修改已有页面 | 补充新信息、扩展内容 |
   | **矛盾** | 标记并讨论 | 新信息与已有结论冲突 |

3. **输出摄取计划**给用户确认：
   ```
   📋 摄取计划（来源: article-name.md）
   
   新增页面:
     - concepts/new-concept — 概念定义
     - entities/new-entity — 实体记录
   
   更新页面:
     - concepts/existing-concept — 补充 X 方面信息
     - entities/existing-entity — 更新 Y 数据
   
   ⚠️ 矛盾检测:
     - concepts/existing → 新数据与旧声明冲突
   
   是否继续？
   ```

### Phase 3: 综合（Synthesize）

用户确认后，按计划执行多页写入：

#### 创建新页面

使用 obsidian-cli（优先）或 Write 工具。遵循 obsidian-markdown 规范（callouts、embeds、wikilinks）。

```bash
# 优先
obsidian create name="concepts/slug" content="# Title\n\nContent" silent

# 降级
# Write 工具 → wiki/concepts/slug.md
```

新页面 frontmatter：
```yaml
---
name: concepts/slug
description: 一句话描述
type: concept | entity | source | synthesis | guide | tutorial | tips
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: ../../archive/sources/filename.md
format: docx | pdf | xlsx | markdown | html | text
status: draft
confidence: medium
---
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `name` | 是 | 页面唯一标识（路径格式） |
| `description` | 是 | 一句话概括 |
| `type` | 是 | 页面类型 |
| `tags` | 建议 | 便于检索 |
| `created/updated` | 建议 | 时间戳 |
| `source` | 建议 | 原始文件路径（归档后更新） |
| `format` | 建议 | 原始文件格式（docx/pdf/xlsx/markdown/html/text） |
| `status` | 建议 | draft/stable/challenged/superseded |
| `confidence` | 建议 | low/medium/high |

#### 更新已有页面

读取现有页面 → 合并新信息 → 写入更新：

1. 保留原有结构和内容
2. 在适当位置**追加新段落**
3. 更新 `updated` 日期
4. 如发现矛盾，添加 callout：
   ```markdown
   > [!warning] 矛盾标记
   > 旧结论: ...（来源: [[source-a]]）
   > 新数据: ...（来源: [[source-b]]）
   > 待确认: 需要进一步验证哪个结论正确
   ```
5. 将 `status` 更新为 `challenged`（如适用）

#### 强化交叉引用

遍历所有受影响的页面，添加新发现的 `[[wikilink]]`：
- 概念页 → 相关实体/概念
- 实体页 → 相关概念/来源
- 来源页 → 提取的概念/实体

### Phase 4: 索引（Index）

#### 更新 index.md

如果 Wiki 使用手动索引（非 Dataview/Bases 自动），追加新条目：
```markdown
- [[concepts/new-concept]] — 一句话描述
```

#### 追加 log.md

追加结构化日志条目：
```markdown
## [YYYY-MM-DD] ingest | Source Title

- 新增: 3 页面（concepts/x, entities/y, sources/z）
- 更新: 2 页面（concepts/a, entities/b）
- 矛盾: 1 处（concepts/c vs 新数据）
- 归档: raw/article.md → archive/sources/article.md
```

### Phase 5: 归档（Archive）

用户确认所有变更后：

```bash
# 移动源文件到归档
mv raw/filename.md archive/sources/filename.md
```

更新所有引用该源文件的页面中 `source` 路径。

## URL 摄取（Web Source）

当用户提供 URL 时，优先使用 defuddle 提取：

```bash
# 优先: defuddle（干净提取，省 token）
defuddle parse <url> --md -o raw/article-title.md

# 降级: WebFetch / fetch MCP
# 手动保存到 raw/
```

提取后自动进入 Phase 1。

## 搜索与去重

**优先使用 obsidian-cli**（需 Obsidian 运行中）:
```bash
obsidian search query="相关关键词" limit=5
obsidian tags sort=count counts
obsidian backlinks file="existing-page"
```

**降级方案**（无 obsidian-cli 时）:
```bash
# 概念搜索
grep -r "关键词" wiki/ --include="*.md" -l

# 标签搜索
grep -r "#tag" wiki/ --include="*.md" -l

# 反向链接搜索
grep -r "\[\[page-name\]\]" wiki/ --include="*.md" -l
```

## 批量摄取

用户可一次性放入多个文件到 `raw/`，按优先级顺序处理：

1. 按文件类型排序（.md → .txt → .html → 其他）
2. 逐个处理，每个都走完整 Phase 1-5
3. 每 5 个文件汇报一次进度
4. 全部完成后统一归档

### 摄入多种格式

使用 docs-ingest 摄入 raw/ 目录中的所有文档：

```bash
# 支持的文件会自动处理
# - document.docx → Wiki 页面
# - spreadsheet.xlsx → Wiki 页面
# - report.pdf → Wiki 页面
# - old.doc → 自动转换后生成 Wiki 页面
```

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 1 个源文件只创建 1 个页面 | 1:N — 识别所有概念/实体，分散到多个页面 |
| 不检查重复直接创建 | Phase 2 映射阶段必须搜索去重 |
| 跳过用户确认 | Phase 2 结束后必须等待确认 |
| 不更新已有页面 | 摄取的核心价值是让已有页面更丰富 |
| 不添加 source 字段 | 归档后更新所有受影响页面的 source 路径 |
| 不检测矛盾 | 新旧信息冲突时添加 warning callout |
| 不更新 index/log | 每次摄取后必须更新索引和日志 |
