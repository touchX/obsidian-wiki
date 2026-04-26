---
name: tips-collection
description: Wiki 实用技巧集 — 提升效率的小技巧
type: tips
tags: [tips, efficiency, wiki]
created: 2026-04-26
updated: 2026-04-26
source: ../../archive/sources/tips-collection.md
---

# Tips Collection

Wiki 实用技巧集。

## 高效技巧

### 1. 快速导航

使用 `[[双括号]]` 快速链接页面：
- 输入 `[[quick` 会弹出自动完成
- Tab 键确认选择

### 2. 批量操作

使用 Bash 脚本批量处理：
```bash
# 批量移动文件
for f in raw/*.md; do
  mv "$f" "archive/$(basename $f)"
done
```

### 3. 搜索技巧

在 Obsidian 中使用搜索语法：
- `tag:#concept` — 按标签搜索
- `path:wiki/concepts` — 按路径搜索

## Frontmatter 快捷键

| 快捷键 | 展开 |
|--------|------|
| `---` | frontmatter 模板 |
| `---` | 分隔线 |
| `[[` | Wiki 链接 |

## 相关页面

- [[quick-start]] — 快速开始
- [[wiki-tutorial]] — 完整教程

---
*Wiki 实用技巧*