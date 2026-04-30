# Obsidian Wiki Skill 使用帮助

> 快速参考指南 — 完整文档见 [README.md](README.md)

## 五大组件速查

| Skill | 触发场景 | 核心命令 |
|-------|----------|----------|
| `obsidian-wiki` | 创建/初始化 Wiki | 运行 install.bat/sh |
| `docs-ingest` | 摄取文档、整理资料 | Phase 1-5 流程 |
| `wiki-query` | 查询、解释、搜索 | Wiki-First + 答案写回 |
| `wiki-lint` | 健康检查、维护 | `bash scripts/lint.sh` |
| `wiki-capture` | 记录经验、沉淀知识 | 会话内容捕获 |
| `learning-tracker` | 学习追踪、智能推荐 | record/analyze/recommend |

## Frontmatter 必需字段

```yaml
---
name: category/slug        # 页面 slug (必需)
description: 一句话描述     # (必需)
type: concept | entity | source | synthesis | guide | tips | tutorial
tags: [tag1, tag2]
created: YYYY-MM-DD        # (必需)
updated: YYYY-MM-DD        # (必需)
---
```

## 常用命令

```bash
# 初始化 Wiki
/path/to/obsidian-wiki/TEMPLATE/scripts/install.sh

# 健康检查
cd wiki && ../scripts/lint.sh

# 记录学习
../learning-tracker/tracker.sh record "topic" 3
../learning-tracker/tracker.sh analyze
```

## 目录用途

| 目录 | 用途 |
|------|------|
| `raw/` | 待处理文件 |
| `raw/notes/` | 会话捕获笔记 |
| `archive/` | 归档存储 |
| `wiki/` | Wiki 知识库 |

## 典型工作流

```
L1: 添加文档 → raw/ → docs-ingest → wiki/ → archive/
L2: 批量摄取 → 矛盾检测 → wiki-query → synthesis 写回
L3: + defuddle 网页摄取 + Bases 动态视图
```

## 状态生命周期

```
draft → stable → (challenged → stable | superseded)
```

---

*基于 Karpathy LLM Wiki 理论构建*
