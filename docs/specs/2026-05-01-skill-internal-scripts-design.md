# Skill 内部脚本架构重构规格

## 背景

obsidian-wiki 项目中，脚本与 skill 的关系不清晰：
- `lint.sh` 出现在 `wiki-lint/` 和 `TEMPLATE/scripts/` 两个位置
- 用户被告知直接运行 `bash scripts/lint.sh`
- 这与"用户只调用 skill，skill 内部调用脚本"的原则冲突

## 目标

1. **脚本对用户透明** — 用户只感知 skill，不知道脚本存在
2. **Skill 自包含** — 每个 skill 的所有文件（SKILL.md + 脚本）都在自己目录下
3. **消除重复** — 删除 TEMPLATE/scripts/lint.sh，只保留 skill 目录中的源文件

## 架构变更

### 当前结构（问题）

```
obsidian-wiki/
├── wiki-lint/
│   ├── SKILL.md
│   └── lint.sh          # ← 在这里
├── TEMPLATE/scripts/
│   ├── install.sh
│   ├── install.bat
│   └── lint.sh          # ← 重复副本！
└── learning-tracker/
    ├── SKILL.md
    ├── tracker.sh
    └── analyzer.sh
```

### 目标结构（解决后）

```
obsidian-wiki/
├── wiki-lint/
│   ├── SKILL.md
│   └── lint.sh          # ← 唯一源
├── TEMPLATE/scripts/
│   ├── install.sh       # ← 项目级安装脚本
│   └── install.bat
└── learning-tracker/
    ├── SKILL.md
    ├── tracker.sh        # ← skill 内部
    └── analyzer.sh       # ← skill 内部
```

### 安装后目标项目结构

```
my-wiki/
├── .claude/skills/
│   ├── wiki-lint/
│   │   ├── SKILL.md
│   │   └── lint.sh      # ← 来自 skill 目录
│   ├── learning-tracker/
│   │   ├── SKILL.md
│   │   ├── tracker.sh
│   │   └── analyzer.sh
│   └── ...
├── scripts/
│   ├── install.sh
│   └── install.bat
└── wiki/
```

## 变更清单

### 1. 删除重复文件

| 删除 | 原因 |
|------|------|
| `TEMPLATE/scripts/lint.sh` | 与 `wiki-lint/lint.sh` 重复 |

### 2. 更新 install.sh

修改 `TEMPLATE/scripts/install.sh`：
- 从 `wiki-lint/lint.sh` 复制到 `.claude/skills/wiki-lint/lint.sh`
- 从 `learning-tracker/tracker.sh` 复制到 `.claude/skills/learning-tracker/tracker.sh`
- 从 `learning-tracker/analyzer.sh` 复制到 `.claude/skills/learning-tracker/analyzer.sh`

### 3. 更新文档（移除直接脚本调用）

| 文件 | 变更 |
|------|------|
| `wiki-lint/SKILL.md` | 移除 `cd wiki && ../scripts/lint.sh`，改为"使用 wiki-lint skill" |
| `HELP.md` | 移除 `bash scripts/lint.sh` 引用 |
| `README.md` | 移除脚本调用说明 |
| `CONTRIBUTING.md` | 移除 `bash scripts/lint.sh` |
| `TEMPLATE/wiki/WIKI.md` | 移除脚本调用说明 |
| `TEMPLATE/wiki/index.md` | 移除脚本路径引用 |
| `TEMPLATE/wiki/guides/quick-start.md` | 移除脚本调用说明 |

### 4. 更新脚本内部注释

标记为"内部使用"：
- `wiki-lint/lint.sh` — 注释更新
- `learning-tracker/tracker.sh` — 注释更新

### 5. 更新 wiki-query SKILL.md

移除直接调用脚本的说明，改为通过 skill 调用。

## 调用流程（对用户透明）

```
用户: "检查 Wiki 健康"
    ↓
AI 调用 wiki-lint skill
    ↓
skill 内部调用 lint.sh
    ↓
返回结果

用户: "查询关于 XXX"
    ↓
AI 调用 wiki-query skill
    ↓
skill 内部调用 learning-tracker/tracker.sh
    ↓
返回答案
```

## 风险与注意事项

1. **向后兼容** — 已有项目升级时需要重新运行 install.sh
2. **文档一致性** — 确保所有引用都已更新
3. **install.sh 测试** — 需要验证所有 skill 文件都被正确复制

## 验收标准

- [ ] TEMPLATE/scripts/lint.sh 已删除
- [ ] install.sh 从 skill 目录读取脚本
- [ ] 所有文档中无直接脚本调用说明
- [ ] 脚本注释标记为"内部使用"
- [ ] wiki-lint skill 仍正常工作
