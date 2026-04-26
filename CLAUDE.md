# CLAUDE.md — obsidian-wiki Skill

Independent Wiki knowledge base system based on Claude Code Best Practice Wiki methodology.

## Project Structure

```
obsidian-wiki/
├── SKILL.md              # Main skill entry
├── docs-ingest/           # Document ingestion
├── wiki-query/            # Wiki query
├── wiki-lint/             # Wiki health check
├── inspool/               # Session knowledge capture
└── TEMPLATE/              # Installation template
    ├── wiki/              # Wiki structure
    ├── scripts/           # Tools
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

## Commands

- `docs-ingest` — Ingest documents into wiki
- `wiki-query` — Query wiki knowledge
- `wiki-lint` — Check wiki health

## Frontmatter Types

- concept, entity, source, synthesis, guide, tutorial, tips