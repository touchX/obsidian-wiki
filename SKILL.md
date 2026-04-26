---
name: obsidian-wiki
description: 独立的 Wiki 知识库系统 — 包含创建、摄取、查询、健康检查全套功能
triggers:
  - "创建 wiki"
  - "创建知识库"
  - "obsidian wiki"
  - "初始化 wiki"
  - "obsidian-wiki init"
requirements:
  - obsidian-cli (https://obsidian.md/cli)
  - obsidian-skills (https://github.com/kepano/obsidian-skills)
---

# Obsidian Wiki Skill

基于 Claude Code Best Practice Wiki 方法论的一站式 Wiki 知识库系统。

## 前置要求

⚠️ **使用前必须安装以下依赖：**

| 依赖 | 安装地址 | 说明 |
|------|----------|------|
| obsidian-cli | https://obsidian.md/cli | Obsidian 命令行工具 |
| obsidian-skills | https://github.com/kepano/obsidian-skills | Skills 插件集合 |

### 检查安装状态

```bash
# 检查 obsidian-cli
obsidian --version

# 检查 obsidian-skills
ls ~/.obsidian/plugins/obsidian-skills/
```

### 未安装提示

如果用户未安装依赖，显示：

```
⚠️ obsidian-wiki 需要以下前置依赖：

1. obsidian-cli
   安装: https://obsidian.md/cli
   npm install -g @obsidianmd/obsidian-utilities-cli

2. obsidian-skills
   安装: https://github.com/kepano/obsidian-skills
   Obsidian 设置 → 社区插件 → 搜索 "obsidian-skills"

请安装后重新运行本技能。
```

## 组件概览

| Skill | 用途 | 触发时机 |
|-------|------|----------|
| `obsidian-wiki/init` | 初始化新 Wiki | 需要创建知识库时 |

## 分层架构

```
obsidian-skills (底层)
├── obsidian-cli        → 页面读写、搜索
├── obsidian-markdown   → frontmatter 规范
└── defuddle            → 网页内容提取
        ↓
Wiki skills (编排层)
├── obsidian-wiki/init  → 初始化创建
├── docs-ingest          → 摄取流程
├── wiki-query           → 查询回答
└── wiki-lint           → 健康检查
```

## 使用流程

### Step 1: 初始化 Wiki

```
使用 Skill: superpowers:obsidian-wiki-init
或直接说: "创建一个新的研究知识库"
```

### Step 2: 添加知识

```
使用 docs-ingest skill 摄取文档
```

### Step 3: 查询知识

```
使用 wiki-query skill 搜索答案
```

### Step 4: 健康检查

```
使用 wiki-lint skill 检查状况
```

## 目录结构

```
{WIKI_PATH}/
├── .obsidian/          # Obsidian 配置
├── archive/            # 归档目录
│   └── {category}/     # 按分类归档
├── docs/               # 文档目录
├── raw/                 # 临时待处理文件
├── scripts/             # 工具脚本
│   └── wiki-lint.sh    # 健康检查
└── wiki/               # Wiki 知识库
    ├── WIKI.md         # Schema 规范
    ├── index.md        # Wiki 索引
    ├── log.md          # 操作日志
    ├── concepts/       # 核心概念
    ├── entities/       # 实体文档
    ├── guides/         # 使用指南
    ├── sources/        # 来源摘要
    ├── synthesis/      # 综合分析
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
source: ../../archive/{category}/filename.md
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

### type 可选值

| 值 | 用途 |
|------|------|
| `concept` | 核心概念定义 |
| `entity` | 实体文档记录 |
| `source` | 来源摘要 |
| `synthesis` | 综合分析 |
| `guide` | 使用指南 |
| `tutorial` | 教程 |
| `tips` | 实用技巧 |

## 三层架构

```
raw/ → [ingest] → wiki/ + archive/
```

| 阶段 | 目录 | 说明 |
|------|------|------|
| 摄入前 | `raw/` | 临时存放待处理源文件 |
| 处理中 | `wiki/` | Wiki 知识库 |
| 处理后 | `archive/` | 源文件归档 |

## 相关 Skills

- `superpowers:docs-ingest` — 文档摄取流程
- `superpowers:wiki-query` — Wiki 查询
- `superpowers:wiki-lint` — Wiki 健康检查

## 安装到项目

将 skills 安装到目标项目的 `.claude/skills/` 目录：

```bash
# Windows
cd TEMPLATE/scripts && install.bat

# Unix/Linux/Mac
cd TEMPLATE/scripts && chmod +x install.sh && ./install.sh
```

安装后，在新项目中直接说 "使用 obsidian-wiki" 即可激活全套 Wiki 功能。

---

## 执行指令

### 当用户请求初始化 Wiki

**检测模式：**
- 用户说："初始化 wiki"、"创建知识库"、"obsidian-wiki init <path>"
- 触发关键词：init、初始化、创建

**执行步骤：**

1. **提取目标路径**
   - 从用户输入中提取目标路径（如 "obsidian-wiki init my-wiki" → "my-wiki"）
   - 如果未提供路径，询问用户："请提供目标路径（如：obsidian-wiki init my-wiki）"

2. **验证路径**
   ```bash
   # 检查路径是否存在
   if [ -d "{target-path}" ]; then
       echo "⚠️ 警告：目标路径已存在"
       echo "是否覆盖？(y/n)"
       # 等待用户确认
   fi
   ```

3. **复制模板文件**
   ```bash
   cp -r TEMPLATE/* {target-path}/
   ```

4. **创建并安装 skills**
   ```bash
   # 创建 skills 目录
   mkdir -p {target-path}/.claude/skills
   
   # 复制主 skill
   cp SKILL.md {target-path}/.claude/skills/obsidian-wiki.md
   
   # 复制子 skills
   mkdir -p {target-path}/.claude/skills/docs-ingest
   cp docs-ingest/SKILL.md {target-path}/.claude/skills/docs-ingest/SKILL.md
   
   mkdir -p {target-path}/.claude/skills/wiki-query
   cp wiki-query/SKILL.md {target-path}/.claude/skills/wiki-query/SKILL.md
   
   mkdir -p {target-path}/.claude/skills/wiki-lint
   cp wiki-lint/SKILL.md {target-path}/.claude/skills/wiki-lint/SKILL.md
   ```

5. **显示完成信息**
   ```
   ✅ Wiki 初始化完成！
   
   已创建：
     - {target-path}/wiki/        - Wiki 知识库
     - {target-path}/archive/     - 归档目录
     - {target-path}/scripts/    - 工具脚本
     - {target-path}/.claude/skills/ - 项目 skills
   
   下一步：
     1. 重启 Claude Code
     2. 在新项目中说 "使用 obsidian-wiki"
     3. 开始添加知识
   ```

---

*基于 Claude Code Best Practice 构建*