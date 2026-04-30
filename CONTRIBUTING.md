# Contributing to obsidian-wiki (v0.2.0)

感谢您对 obsidian-wiki 项目的关注！本文档指导您如何参与贡献。

## 项目架构

obsidian-wiki 是一个基于 Claude Code Best Practice Wiki 方法论的独立知识库系统。

```
obsidian-wiki/
├── SKILL.md              # 主技能入口
├── CLAUDE.md              # Claude Code 项目配置
├── README.md              # 用户文档
├── CONTRIBUTING.md        # 本文件
├── docs-ingest/           # 文档摄取技能
├── wiki-query/            # Wiki 查询技能
├── wiki-lint/             # 健康检查技能
├── wiki-capture/          # 会话知识沉淀
├── learning-tracker/      # 学习活动追踪与分析
└── TEMPLATE/              # 安装模板
    ├── wiki/              # Wiki 结构示例
    ├── scripts/           # 工具脚本
    └── .obsidian/         # Obsidian 配置 + 插件
```

## 开发环境设置

### 前置要求

| 依赖 | 安装地址 |
|------|----------|
| **Git** | https://git-scm.com/ |
| **Node.js** | https://nodejs.org/ |
| **obsidian-cli** | `npm install -g @obsidianmd/obsidian-utilities-cli` |
| **Obsidian** | https://obsidian.md/ |

### 克隆项目

```bash
# 克隆主仓库（请替换为实际仓库地址）
git clone https://github.com/<YOUR_USERNAME>/obsidian-wiki.git
cd obsidian-wiki

# 或者作为子模块添加到现有项目
git submodule add https://github.com/<YOUR_USERNAME>/obsidian-wiki.git docs/superpowers/obsidian-wiki
```

## 贡献类型

### 文档改进
- 修正错误、补充遗漏
- 提升说明清晰度
- 添加使用示例

### Skill 开发
- 新增技能（如 `wiki-export`）
- 优化现有技能流程
- 改进错误处理

### Wiki 模板优化
- 添加新类型页面模板
- 优化 frontmatter 示例
- 改进目录结构

### 工具脚本
- 增强 wiki-lint skill 功能
- 添加自动化工具
- 性能优化

## 开发规范

### Frontmatter 标准（必须）

所有 Wiki 页面必须包含以下 frontmatter：

```yaml
---
name: category/slug              # 必需：页面 slug
description: 一句话描述           # 必需
type: concept|entity|source|synthesis|guide|tutorial|tips  # 必需
tags: [tag1, tag2]              # 必需：标签数组
created: YYYY-MM-DD             # 必需：创建日期
updated: YYYY-MM-DD             # 必需：更新日期
status: draft|stable|challenged|superseded  # 建议：知识状态
confidence: low|medium|high     # 建议：置信度
source: ../../archive/sources/.. # 建议：源文件路径
---
```

### Type 类型说明

| Type | 用途 | 示例 |
|------|------|------|
| `concept` | 核心概念定义 | "Wiki 知识库方法论" |
| `entity` | 实体文档记录 | "项目 X 技术栈" |
| `source` | 外部来源摘要 | "论文 Y 要点" |
| `synthesis` | 综合分析 | "技术选型对比" |
| `guide` | 使用指南 | "快速上手指南" |
| `tutorial` | 教程 | "如何创建 Wiki 页面" |
| `tips` | 实用技巧 | "Wiki 维护技巧" |

### Skill 开发规范

每个 Skill 必须包含：

1. **Frontmatter**（YAML）
   ```yaml
   ---
   name: skill-name
   description: 一句话说明技能用途
   triggers:
     - "触发关键词1"
     - "触发关键词2"
   requirements:
     - 依赖1 (如有)
   ---
   ```

2. **使用场景**（When to Use）
   - 触发条件
   - 识别症状

3. **核心流程**（Core Pattern）
   - 流程图（dot 格式）
   - 关键步骤说明

4. **实际命令**（Real Commands）
   - 可执行的 shell 命令
   - obsidian-cli 示例

5. **常见错误**（Common Mistakes）
   - 错误做法 vs 正确做法对照表

## 开发流程

### 1. 创建分支

```bash
git checkout -b feature/your-feature-name
# 或
git checkout -b fix/your-bug-fix
```

### 2. 开发与测试

```bash
# 运行 Wiki 健康检查（使用 wiki-lint skill）
# 在 Claude Code 中说：使用 wiki-lint

# 测试技能（需要 Claude Code 运行中）
# 在 Claude Code 中说：使用 <skill-name>
```

### 3. 提交前检查

- [ ] 所有新增页面包含完整 frontmatter
- [ ] source 路径指向 archive/ 中的实际文件
- [ ] 使用 wiki-lint skill 检查无错误
- [ ] 代码/文档符合项目规范
- [ ] 更新相关文档（README.md, WIKI.md 等）

### 4. 提交更改

```bash
git add .
git commit -m "type: description"
```

**Commit Message 格式：**

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加 wiki-export 技能` |
| `fix` | Bug 修复 | `fix: 修正 source 路径示例` |
| `docs` | 文档更新 | `docs: 更新 CONTRIBUTING.md` |
| `refactor` | 代码重构 | `refactor: 优化 wiki-lint 流程` |
| `test` | 测试相关 | `test: 添加技能测试用例` |
| `chore` | 构建/工具 | `chore: 更新插件依赖` |

### 5. Pull Request

```bash
git push origin feature/your-feature-name
```

然后在 GitHub 上创建 Pull Request。

**PR 标题格式：** `[type] Short description`

**PR 描述模板：**

```markdown
## 变更说明
简要描述本次变更的内容和目的。

## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 文档改进
- [ ] 性能优化
- [ ] 代码重构

## 测试情况
描述测试环境和测试结果。

## 截图/演示
（如适用）

## Checklist
- [ ] 代码符合项目规范
- [ ] 已通过 wiki-lint 检查
- [ ] 已更新相关文档
- [ ] 无合并冲突
```

## Issue 报告

### Bug 报告

```markdown
**Bug 描述**
清晰简洁地描述 bug。

**复现步骤**
1. 执行操作 A
2. 点击按钮 B
3. 观察到错误 C

**预期行为**
描述应该发生的正确行为。

**环境信息**
- OS: [e.g. Windows 11]
- Obsidian 版本: [e.g. 1.5.0]
- obsidian-cli 版本: [e.g. 0.5.0]
- Claude Code 版本: [e.g. 1.2.0]

**额外信息**
日志、截图、错误信息等。
```

### 功能建议

```markdown
**功能描述**
清晰简洁地描述建议的功能。

**使用场景**
描述这个功能解决什么问题，在什么场景下使用。

**实现建议**
（可选）您对如何实现这个功能的想法。

**替代方案**
（可选）您考虑过的其他解决方案。
```

## 测试要求

### Wiki 页面测试

```bash
# 1. Frontmatter 完整性检查
grep -c "^---" wiki/**/*.md

# 2. 交叉引用有效性检查
grep -r '\[\[' wiki/ --include="*.md" | while read link; do
  target=$(echo $link | sed 's|.*\[\[.*\]\].*||')
  [ -f "wiki/$target.md" ] || echo "Broken: $target"
done

# 3. Source 路径检查
grep "^source:" wiki/**/*.md | while read line; do
  file=$(echo $line | sed 's|.*source: ||')
  [ -f "$file" ] || echo "Missing: $file"
done
```

### Skill 测试

在 Claude Code 中测试技能：

```
测试场景：用户说 "创建一个研究 Wiki"

预期行为：
1. 识别 obsidian-wiki init 触发
2. 提取目标路径
3. 复制 TEMPLATE 文件
4. 创建 skills 目录
5. 显示完成信息
```

## 代码审查

### 审查重点

1. **Frontmatter 规范**
   - 所有必需字段是否存在
   - type 值是否在允许列表内
   - 日期格式是否正确

2. **路径一致性**
   - source 路径是否指向 archive/
   - 相对路径计算是否正确

3. **文档清晰度**
   - 说明是否易于理解
   - 示例是否可运行
   - 流程图是否准确

4. **技能完整性**
   - 是否包含所有必需章节
   - 命令示例是否可执行
   - 错误处理是否考虑

## 发布流程

仅维护者需要执行：

1. 更新版本号（在 SKILL.md 和 README.md 中）
2. 更新 CHANGELOG.md
3. 创建 Git tag: `git tag -a v1.x.x -m "Release v1.x.x"`
4. 推送 tag: `git push origin v1.x.x`
5. GitHub 创建 Release

## 社区规范

### 行为准则

- 尊重所有贡献者
- 建设性反馈，鼓励讨论
- 专注于解决问题，而非指责

### 沟通渠道

- **GitHub Issues**: 问题报告和功能讨论
- **Pull Requests**: 代码审查和技术讨论
- **Wiki**: 文档和知识共享

## 许可证

贡献的代码将采用 MIT 许可证发布。

---

**再次感谢您的贡献！** 🎉

如有疑问，请在 GitHub Issues 中提出。
