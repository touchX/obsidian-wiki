---
name: wiki-lint
description: Wiki 健康检查与知识演化技能。当用户要求检查 Wiki 状况、验证 frontmatter、检查链接有效性、检测知识矛盾、发现孤立页面、定期维护 Wiki 时必须使用。添加新页面后也应主动运行检查。
---

# Wiki 健康检查技能（含知识演化检测）

验证 frontmatter 完整性、交叉引用有效性、source 路径正确性，并检测知识矛盾、孤立页面和知识缺口。

## 触发条件

- 定期 Wiki 维护
- 添加新页面后验证
- 发现链接失效问题
- 报告 Wiki 健康状况
- 怀疑知识存在矛盾

## 执行步骤

1. **统计页面**: 按分类统计 wiki/ 下各目录的 .md 文件数
2. **检查 Frontmatter**: 验证必需字段
3. **验证交叉引用**: 检查所有 `[[链接]]` 目标是否存在
4. **检查 source 路径**: 验证 source 字段指向的文件是否存在
5. **检测孤立页面**: 找出没有任何入站链接的页面
6. **检测知识矛盾**: 找出被标记为 challenged 的内容
7. **发现知识缺口**: 识别被提及但未独立建页的概念
8. **生成报告**: 汇总问题清单和改进建议

## 运行方式

**使用 lint 脚本**:
```bash
cd wiki && ../scripts/lint.sh
```

**矛盾检测**（LLM 辅助，脚本无法自动完成）:
```bash
# 查找所有被标记为 challenged 的页面
grep -r "status: challenged" wiki/ --include="*.md" -l

# 查找 warning callout（矛盾标记）
grep -r "\[!warning\]" wiki/ --include="*.md" -A3
```

**孤立页面检测**:
```bash
# 列出所有页面
find wiki/ -name "*.md" | sed 's/wiki\///;s/\.md$//' | sort > /tmp/all_pages.txt

# 列出被引用的页面
grep -roh '\[\[[^]]*\]\]' wiki/ | sed 's/\[\[//;s/\]\]//;s/|.*//' | sort -u > /tmp/linked_pages.txt

# 找出孤立页面（未被任何页面引用）
comm -23 /tmp/all_pages.txt /tmp/linked_pages.txt
```

## 扩展 Frontmatter 标准

在原有必需字段基础上，增加可选的知识演化字段：

| 字段 | 必需 | 说明 |
|------|------|------|
| `status` | 建议 | `draft` \| `stable` \| `challenged` \| `superseded` |
| `confidence` | 建议 | `low` \| `medium` \| `high` |
| `contradicts` | 可选 | 与之矛盾的页面 `[[page]]` |
| `superseded_by` | 可选 | 取代本文的页面 `[[page]]` |
| `sources` | 可选 | 知识来源页面列表 |

### status 生命周期

```
draft → stable → (challenged → stable | superseded)
```

- `draft`: 新创建，未充分验证
- `stable`: 经过验证的可靠知识
- `challenged`: 新证据提出质疑，待确认
- `superseded`: 已被更新的页面取代

## 输出格式

报告写入 `wiki/WIKI-LINT-REPORT.md`，包含：
- 页面统计
- Frontmatter 问题
- 交叉引用问题
- Source 引用问题
- 孤立页面列表
- 知识矛盾清单
- 建议新建页面的概念列表
- 总结（问题总数 + 改进建议）

## 知识缺口发现

在检查过程中，如果发现以下模式，建议创建新页面：
- 多个页面都提到同一概念但没有 `[[链接]]`
- 某个概念在 3+ 个页面中出现但缺乏独立解释
- 某个实体被频繁引用但只有内联描述

建议格式：
```
💡 知识缺口建议:
  - "概念X" 在 5 个页面中被提及但无独立页面
  - "实体Y" 在 3 个页面中被引用但缺乏详细记录
  建议运行 docs-ingest 或手动创建这些页面。
```

## 必需 Frontmatter 字段

所有 Wiki 页面必须包含: `name`, `description`, `type`, `tags`, `created`, `updated`。
详细标准参见主技能 `obsidian-wiki` SKILL.md。

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 只检查格式不检查知识质量 | 增加矛盾和缺口检测 |
| 不识别孤立页面 | 用交叉引用分析找出孤立页 |
| 报告只有问题没有建议 | 每类问题附带修复建议 |
