# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup with 5 core skills (init, docs-ingest, wiki-query, wiki-lint, wiki-capture)
- TEMPLATE directory with complete Obsidian vault structure
- Wiki schema with frontmatter standards and page type definitions
- 8 pre-configured Obsidian plugins (dataview, calendar, claudian, omnisearch, etc.)
- wiki-lint.sh script for Wiki health checks
- install.bat/install.sh for skills installation

### Documentation
- SKILL.md - Main skill entry with architecture overview
- HELP.md - Quick reference guide
- README.md - Project introduction
- CONTRIBUTING.md - Contribution guidelines
- llm-wiki.md - Karpathy LLM Wiki theory reference
- TEMPLATE/wiki/WIKI.md - Wiki schema specification

### Skills
- **obsidian-wiki**: Wiki initialization and orchestration
- **docs-ingest**: 1:N multi-page document ingestion with contradiction detection
- **wiki-query**: Wiki-First query with answer write-back (knowledge compounding)
- **wiki-lint**: Wiki health check with orphan/contradiction detection
- **wiki-capture**: Session knowledge capture to raw/notes/

---

## [0.1.0] - 2026-04-26

### Added
- Initial release
