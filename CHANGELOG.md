# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-04-30

### Added

- **Learning Tracker 智能学习进化系统**
  - `learning-tracker.sh` — 用户学习活动追踪（主题频率、难度、连续天数）
  - `analyzer.sh` — 学习分析器（生成推荐和报告）
  - 双轨数据结构：`config/user-activity.json` + Wiki frontmatter
  - 遗忘提醒：超过 7 天未访问的主题主动提醒

- **Wiki-First 查询机制**
  - `wiki-query` skill — 答案写回 synthesis 页面
  - 智能推荐触发：高频主题、基础概念缺失检测

- **用户帮助系统**
  - `HELP.md` — 快速参考指南
  - `llm-wiki.md` — Karpathy LLM Wiki 理论完整翻译

- **Gitignore 配置**
  - 忽略 `.obsidian/plugins/` 下载目录

### Fixed

- **代码健壮性**
  - `install.sh/bat` — 修复 skill 复制路径不一致问题
  - `learning-tracker.sh` — 修复 total_queries 从未持久化的 bug
  - `update_wiki_page_query` — 修复查找逻辑和目录列表不一致
  - `update_wiki_page_query` — 修复正则表达式误匹配问题

- **文档一致性**
  - 修正 SKILL.md 组件表格（init 非独立技能）
  - 修正 archive 目录结构理解
  - 修正 source 路径引用格式
  - 修复断链和完善 type 枚举文档

- **安装脚本**
  - `init` 命令添加缺失目录创建步骤
  - 添加错误处理和一致的输出格式

### Changed

- **文档重构**
  - 重新设计 README，突出知识复利核心理念
  - 完善文档结构与渐进式复杂度体系（L1-L4）

- **预配置插件列表**（12 个）
  - dataview, calendar, claudian, omnisearch
  - obsidian-excalidraw-plugin, templater-obsidian
  - obsidian-local-rest-api, tag-wrangler
  - file-explorer-note-count, obsidian-branding
  - obsidian-custom-attachment-location, recent-files-obsidian

---

## [0.1.0] - 2026-04-26

### Added

- **核心技能**（5 个）
  - `obsidian-wiki` — 初始化与编排
  - `docs-ingest` — 多页综合摄取（1:N）
  - `wiki-query` — Wiki-First 查询
  - `wiki-lint` — 健康检查
  - `wiki-capture` — 会话知识捕获

- **TEMPLATE 结构**
  - 完整 Obsidian vault 模板（`.obsidian/plugins/`）
  - Wiki schema 规范（`WIKI.md`）
  - 6 种页面类型示例（concepts, entities, sources, synthesis, guides, tips）
  - 安装脚本（`install.sh`, `install.bat`）

- **LLM Wiki 理论**
  - Karpathy LLM Wiki 方法论完整文档
  - 知识复利理念：Wiki 是持久增长的复利资产

---

*Based on Andrej Karpathy's LLM Wiki theory*
