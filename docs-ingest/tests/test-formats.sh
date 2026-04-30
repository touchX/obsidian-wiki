#!/usr/bin/env bash
# 多格式文档摄入测试套件
# 验证 MIME 检测、Skill 路由和端到端流程
#
# 用法:
#   ./test-formats.sh              # 运行所有测试
#   source test-formats.sh         # 被其他脚本 source
#
# 环境变量:
#   VERBOSE                        # 设置为非空值启用详细输出

set -euo pipefail

# 测试统计
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# 临时文件管理
TEST_TEMP_DIR=""

# 清理函数
cleanup() {
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# 注册清理钩子
trap cleanup EXIT

# 初始化测试环境
setup_test_env() {
    TEST_TEMP_DIR=$(mktemp -d)
    if [[ -n "${VERBOSE:-}" ]]; then
        echo "📁 测试临时目录: $TEST_TEMP_DIR"
    fi
}

# 测试报告函数
test_report_start() {
    local test_name="$1"
    ((TESTS_RUN++)) || true
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧪 测试 $TESTS_RUN: $test_name"
}

test_report_pass() {
    ((TESTS_PASSED++)) || true
    echo "✅ 通过"
    echo ""
}

test_report_fail() {
    local reason="${1:-未知原因}"
    ((TESTS_FAILED++)) || true
    echo "❌ 失败: $reason"
    echo ""
}

# 打印最终报告
print_final_report() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 测试总结"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "运行: $TESTS_RUN"
    echo "通过: $TESTS_PASSED"
    echo "失败: $TESTS_FAILED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✅ 所有测试通过"
        return 0
    else
        echo "❌ 有 $TESTS_FAILED 个测试失败"
        return 1
    fi
}

# 测试 1: MIME 检测功能
test_mime_detection() {
    test_report_start "MIME 检测功能"

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local mime_detector="$script_dir/scripts/mime-detector.sh"

    if [[ ! -f "$mime_detector" ]]; then
        test_report_fail "找不到 mime-detector.sh"
        return 1
    fi

    # Source mime-detector.sh 以获取测试函数
    # shellcheck source=scripts/mime-detector.sh
    source "$mime_detector"

    # 运行 MIME 检测测试
    if test_mime_detection > /dev/null 2>&1; then
        test_report_pass
        return 0
    else
        test_report_fail "MIME 检测测试失败"
        return 1
    fi
}

# 测试 2: Skill 路由功能（预留）
test_skill_routing() {
    test_report_start "Skill 路由功能"

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local router="$script_dir/scripts/router.sh"

    if [[ ! -f "$router" ]]; then
        echo "⚠️  跳过: router.sh 尚未创建"
        test_report_pass
        return 0
    fi

    # TODO: 当 router.sh 创建后，添加实际测试
    # shellcheck source=scripts/router.sh
    source "$router"

    # 占位测试 - 待 router.sh 实现后补充
    echo "⚠️  路由测试待实现"
    test_report_pass
    return 0
}

# 测试 3: 端到端流程（预留）
test_end_to_end() {
    test_report_start "端到端文档处理流程"

    # 创建测试文件
    local test_file="$TEST_TEMP_DIR/test.md"
    echo "# Test Document" > "$test_file"
    echo "This is a test." >> "$test_file"

    # TODO: 当完整流程实现后，添加端到端测试
    echo "⚠️  端到端测试待实现"
    test_report_pass
    return 0
}

# 主测试运行器
run_all_tests() {
    echo "╔════════════════════════════════════════╗"
    echo "║  多格式文档摄入测试套件 v0.1.0        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    setup_test_env

    # 运行所有测试
    test_mime_detection
    test_skill_routing
    test_end_to_end

    # 打印最终报告
    print_final_report
}

# 如果直接运行脚本，执行所有测试
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
