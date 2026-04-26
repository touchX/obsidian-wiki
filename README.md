# Obsidian Wiki Skill

基于 Claude Code Best Practice Wiki 方法论的 Obsidian Wiki 知识库快速创建工具。

## 前置要求

⚠️ **使用前必须安装以下依赖：**

| 依赖 | 安装地址 |
|------|----------|
| obsidian-cli | https://obsidian.md/cli |
| obsidian-skills | https://github.com/kepano/obsidian-skills |

### 安装步骤

```bash
# 1. 安装 obsidian-cli
npm install -g @obsidianmd/obsidian-utilities-cli

# 2. 安装 obsidian-skills（Obsidian 插件）
#    Obsidian 设置 → 社区插件 → 搜索 "obsidian-skills"

# 3. 验证安装
obsidian --version
```

## 功能

- 一键创建完整的 Wiki 知识库结构
- 标准化 Frontmatter 和目录组织
- 内置 Wiki 健康检查脚本
- 预配置 Obsidian Vault 设置

## 预配置插件

TEMPLATE 包含以下预配置插件：

| 插件 | 用途 |
|------|------|
| **dataview** | 数据查询和索引自动生成 — 自动维护 wiki/index.md |
| **calendar** | 日历视图 — 按日期浏览 Wiki 操作日志 |
| **claudian** | Claude Code 集成 — 与 Claude CLI 交互 |
| **obsidian-branding** | 界面美化 — 统一视觉风格 |

## 目录结构

```
project/
├── .obsidian/          # Obsidian 配置
├── archive/            # 归档目录
├── docs/                # 文档目录
├── raw/                 # 临时存放待处理文件
├── scripts/             # 工具脚本
└── wiki/                # Wiki 知识库
    ├── concepts/        # 核心概念
    ├── entities/         # 实体文档
    ├── guides/          # 使用指南
    ├── synthesis/        # 综合分析
    ├── tips/             # 实用技巧
    └── tutorial/         # 教程
```

## 使用流程

### 1. 初始化 Wiki

```bash
# 创建新的 Wiki 目录
mkdir my-wiki
cd my-wiki

# 复制模板（手动操作）
# 将 TEMPLATE/ 目录复制到目标位置

# 或使用 obsidian-wiki skill 交互式初始化
```

### 2. 添加知识

1. 将源文档放入 `raw/` 目录
2. 使用 `docs-ingest` skill 摄取
3. 文档自动归档到 `archive/`

### 3. 查询知识

1. 读取 `wiki/index.md` 了解结构
2. 使用 Wiki 链接 `[[page]]` 浏览
3. 综合多个页面回答问题

### 4. 健康检查

```bash
cd wiki && ../scripts/wiki-lint.sh
```

## Frontmatter 标准

```markdown
---
name: page-slug
description: 一句话描述
type: concept | entity | source | synthesis | guide
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: ../../archive/sources/filename.md
---
```

## 页面类型

| 类型 | 用途 |
|------|------|
| `concept` | 核心概念定义 |
| `entity` | 实体文档记录 |
| `source` | 来源摘要 |
| `synthesis` | 综合分析 |
| `guide` | 使用指南 |

## 相关资源

- [Wiki Schema 规范](wiki/WIKI.md) — 完整架构说明
- [设计规范](../specs/2026-04-26-obsidian-wiki-design.md) — Skill 设计文档

---

*基于 Claude Code Best Practice 构建*