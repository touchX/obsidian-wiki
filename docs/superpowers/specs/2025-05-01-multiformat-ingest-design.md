# 多格式文档摄入扩展设计

**日期**: 2025-05-01
**版本**: 1.0
**状态**: 设计阶段

## 概述

扩展 obsidian-wiki 的 `docs-ingest` skill，支持多种文档格式的摄入和转换，包括 Word (.docx/.doc)、Excel (.xlsx/.xls)、PDF 等格式，采用中心化调度器架构。

## 设计目标

1. **统一入口** — docs-ingest 作为中心调度器，处理所有格式
2. **智能检测** — 使用 MIME 类型识别文件格式
3. **预转换层** — 自动将旧格式（.doc/.xls）转换为现代格式
4. **双轨模式** — 同时生成 Wiki 页面（可编辑）和原始文件归档（可查阅）
5. **格式元数据** — 在 frontmatter 中记录原始格式

## 整体架构

```
docs-ingest (中心调度器)
│
├── MIME 检测模块
│   └── file --mime-type <文件>
│
├── 预转换层（新增）
│   ├── application/msword → .docx
│   ├── application/vnd.ms-excel → .xlsx
│   └── application/vnd.ms-powerpoint → .pptx
│
├── Skill 路由表
│   ├── application/pdf → pdf skill
│   ├── application/vnd.openxmlformats...docx → docx skill
│   ├── application/vnd.openxmlformats...xlsx → xlsx skill
│   ├── text/markdown → internal
│   └── text/html → defuddle
│
└── 统一处理流程
    ├── 调用对应格式 skill
    ├── 接收 Markdown 转换结果
    ├── 智能分析内容类型
    ├── 生成 Wiki 页面（带 format 字段）
    └── 归档原始文件
```

## 组件设计

### 1. MIME 检测模块

**文件**: `docs-ingest/scripts/mime-detector.sh`

```bash
detect_mime_type() {
    local file="$1"
    local mime
    
    # 使用 file 命令检测 MIME 类型
    mime=$(file --mime-type -b "$file" 2>/dev/null)
    
    # 降级方案：基于扩展名
    if [ -z "$mime" ] || [[ "$mime" == "text/plain" ]]; then
        local ext="${file##*.}"
        case "$ext" in
            docx) echo "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ;;
            xlsx) echo "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ;;
            pdf)  echo "application/pdf" ;;
            md)   echo "text/markdown" ;;
            doc)  echo "application/msword" ;;
            xls)  echo "application/vnd.ms-excel" ;;
            *)    echo "unknown/$ext" ;;
        esac
    else
        echo "$mime"
    fi
}
```

### 2. 预转换层

**文件**: `docs-ingest/scripts/preconvert.sh`

处理旧格式文件（.doc/.xls/.ppt）转换为现代格式：

```bash
preconvert_legacy_format() {
    local file="$1"
    local mime="$2"
    local base_name="${file%.*}"
    
    case "$mime" in
        application/msword)
            # .doc → .docx
            python scripts/office/soffice.py --headless --convert-to docx "$file"
            echo "${base_name}.docx"
            ;;
        application/vnd.ms-excel)
            # .xls → .xlsx
            python scripts/office/soffice.py --headless --convert-to xlsx "$file"
            echo "${base_name}.xlsx"
            ;;
        *)
            # 不需要转换
            echo "$file"
            ;;
    esac
}
```

### 3. Skill 路由表

**文件**: `docs-ingest/scripts/router.sh`

MIME 类型到 Skill 的映射：

```bash
declare -A MIME_TO_SKILL=(
    ["application/pdf"]="pdf"
    ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"]="docx"
    ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]="xlsx"
    ["text/markdown"]="internal"
    ["text/html"]="defuddle"
)

get_skill_for_mime() {
    local mime="$1"
    echo "${MIME_TO_SKILL[$mime]:-unknown}"
}
```

## 数据流

```
用户调用 docs-ingest
    │
    ▼
扫描 raw/ 目录
    │
    ├─→ MIME 检测
    │       │
    │       ▼
    │   预转换层（旧格式 → 现代格式）
    │       │
    │       ▼
    │   Skill 路由
    │       │
    │       ├─→ pdf skill
    │       ├─→ docx skill
    │       ├─→ xlsx skill
    │       ├─→ internal (markdown)
    │       └─→ defuddle (html)
    │
    ▼
格式 skill 返回 Markdown
    │
    ▼
智能内容分析
    │
    ├─→ 提取标题、结构
    ├─→ 识别内容类型
    └─→ 生成 frontmatter
    │
    ▼
生成 Wiki 页面
    │
    ├─→ 添加 format 字段
    ├─→ 设置 source 指向原始文件
    └─→ 写入 wiki/{concepts|entities|sources}/
    │
    ▼
归档原始文件
    │
    └─→ archive/sources/
```

## Frontmatter 扩展

### 新增字段

```yaml
---
name: {category}/{slug}
description: 一句话描述
type: concept | entity | source | synthesis | guide | tutorial | tips
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: ../../archive/sources/filename.docx
format: docx | pdf | xlsx | markdown | html | text
status: draft | stable | challenged | superseded
confidence: low | medium | high
# --- 智能进化字段 ---
query_count: 0
last_queried: YYYY-MM-DD
difficulty_level: 3
learning_path: next
---
```

### format 字段说明

| 值 | 说明 | 示例 |
|-----|------|------|
| `docx` | Word 文档（.docx） | `format: docx` |
| `pdf` | PDF 文档 | `format: pdf` |
| `xlsx` | Excel 表格 | `format: xlsx` |
| `markdown` | Markdown 文件 | `format: markdown` |
| `html` | 网页 | `format: html` |
| `text` | 纯文本 | `format: text` |

### format 字段用途

1. **溯源** — 快速识别原始格式
2. **过滤** — 按格式筛选页面（Bases 视图）
3. **统计** — 了解知识库的格式分布
4. **重处理** — 需要时可根据 format 重新提取

## 支持的格式

| 格式 | MIME | Skill | 预处理 | 状态 |
|------|------|-------|--------|------|
| PDF | application/pdf | pdf | 无 | ✅ |
| Word (.docx) | vnd.openxmlformats...docx | docx | 无 | ✅ |
| Word (.doc) | application/msword | docx | LibreOffice 转换 | ✅ |
| Excel (.xlsx) | vnd.openxmlformats...xlsx | xlsx | 无 | ✅ |
| Excel (.xls) | application/vnd.ms-excel | xlsx | LibreOffice 转换 | ✅ |
| Markdown | text/markdown | internal | 无 | ✅ |
| HTML | text/html | defuddle | 无 | ✅ |
| 纯文本 | text/plain | internal | 无 | ✅ |

## 错误处理

### 错误类型

```bash
declare -A ERROR_CODES=(
    ["E_DETECTION_FAILED"]=1    # MIME 检测失败
    ["E_CONVERSION_FAILED"]=2   # 格式转换失败
    ["E_SKILL_NOT_FOUND"]=3     # 对应 skill 不存在
    ["E_SKILL_FAILED"]=4        # skill 执行失败
    ["E_INVALID_OUTPUT"]=5      # skill 输出无效
    ["E_ARCHIVE_FAILED"]=6      # 文件归档失败
    ["E_WIKI_WRITE_FAILED"]=7   # Wiki 写入失败
)
```

### 重试机制

对于网络相关或临时性错误，实现自动重试：
- 最大重试次数：3
- 退避策略：延迟时间指数增长（2s → 4s → 8s）

## 测试策略

### 单元测试

1. **MIME 检测测试** — 验证各种文件格式的正确识别
2. **Skill 路由测试** — 验证 MIME 到 Skill 的映射
3. **预转换测试** — 验证旧格式转换功能

### 集成测试

1. **端到端流程** — 从原始文件到 Wiki 页面的完整流程
2. **多格式批量处理** — 混合格式文件的处理能力
3. **错误恢复** — 各种失败场景的处理

## 文件清单

### 新增文件

```
docs-ingest/
├── scripts/
│   ├── mime-detector.sh       # MIME 检测
│   ├── preconvert.sh          # 预转换层
│   └── router.sh              # Skill 路由
├── config/
│   └── formats.conf           # 格式配置
└── tests/
    └── test-formats.sh        # 测试套件
```

### 修改文件

```
docs-ingest/
└── SKILL.md                   # 更新架构说明
```

## 实施计划

### 阶段 1：基础框架
1. 实现 MIME 检测模块
2. 实现 Skill 路由表
3. 更新 docs-ingest 主流程

### 阶段 2：预转换层
1. 实现预转换层
2. 集成 LibreOffice 转换
3. 添加错误处理

### 阶段 3：集成测试
1. 编写测试用例
2. 端到端测试
3. 文档完善

## 依赖项

### 外部依赖

- **LibreOffice** — 用于旧格式转换（.doc/.xls）
- **file 命令** — MIME 类型检测

### 内部依赖

- **docx skill** — Word 文档处理
- **xlsx skill** — Excel 表格处理
- **pdf skill** — PDF 文档处理

## 风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| LibreOffice 未安装 | 无法转换旧格式 | 提供降级方案，记录警告 |
| MIME 检测不准确 | 路由到错误 skill | 扩展名降级方案 |
| Skill 执行失败 | 文档无法处理 | 错误日志，跳过继续 |
| 转换超时 | 处理卡住 | 超时机制，记录失败 |

## 未来扩展

1. **更多格式** — PPTX、EPUB、图片（OCR）等
2. **批量优化** — 并行处理多个文件
3. **增量处理** — 仅处理变更文件
4. **格式统计** — 知识库格式分布分析

---

*设计版本 1.0 | 2025-05-01*
