# CLAUDE.md — obsidian-wiki Skill (v0.2.0)

Independent Wiki knowledge base system based on Karpathy LLM Wiki theory.

## Project Structure

```
obsidian-wiki/
├── SKILL.md              # Main skill entry
├── docs-ingest/           # Multi-page document ingestion
├── wiki-query/            # Wiki query with answer write-back
├── wiki-lint/             # Wiki health check (orphan, contradiction)
├── wiki-capture/          # Session knowledge capture
├── learning-tracker/      # Learning activity tracking & analytics
└── TEMPLATE/              # Installation template
    ├── wiki/              # Wiki structure
    │   ├── WIKI.md        # Schema spec
    │   ├── wiki-index.base # Bases dynamic index
    │   └── ...
    ├── scripts/           # Installation tools only
    │   ├── install.sh
    │   └── install.bat
    └── .obsidian/         # Obsidian config + plugins
```

## Dependencies

- obsidian-cli: https://obsidian.md/cli
- obsidian-skills: https://github.com/kepano/obsidian-skills

## Usage

1. Install dependencies
2. Copy TEMPLATE to target project
3. Run install.bat/install.sh
4. Use skills via Claude Code

## Skills

| Skill | Purpose |
|-------|---------|
| `docs-ingest` | 1:N multi-page synthesis ingestion |
| `wiki-query` | Query wiki with answer write-back |
| `wiki-lint` | Health check + orphan/contradiction detection |
| `wiki-capture` | Session knowledge capture |
| `learning-tracker` | Learning activity tracking & analytics |

## Frontmatter Types

- concept, entity, source, synthesis, guide, tutorial, tips

## Status Lifecycle

```
draft → stable → (challenged → stable | superseded)
```