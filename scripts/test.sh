#!/bin/sh

set -e

BINARY="./zig-out/bin/boxsay"
PASSED=0
FAILED=0

pass() {
    echo "✓ $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "✗ $1"
    if [ -n "$2" ]; then
        echo "  $2"
    fi
    FAILED=$((FAILED + 1))
}

test_contains() {
    local output="$1"
    local pattern="$2"
    local name="$3"
    
    if printf '%s' "$output" | grep -qF -- "$pattern"; then
        pass "$name"
    else
        fail "$name" "Expected pattern: $pattern"
    fi
}

test_matches() {
    local output="$1"
    local pattern="$2"
    local name="$3"
    
    if printf '%s' "$output" | grep -qE "$pattern"; then
        pass "$name"
    else
        fail "$name" "Expected pattern: $pattern"
    fi
}

echo "Building..."
zig build -Doptimize=ReleaseFast
echo ""

echo "Running tests..."
echo ""

echo "=== Styles ==="

test_matches "$($BINARY -s classic "test")" "┌.*┐" "classic: corners"
test_matches "$($BINARY -s classic "test")" "└.*┘" "classic: bottom corners"

test_matches "$($BINARY -s rounded "test")" "╭.*╮" "rounded: top corners"
test_matches "$($BINARY -s rounded "test")" "╰.*╯" "rounded: bottom corners"

test_matches "$($BINARY -s heavy "test")" "┏.*┓" "heavy: top corners"
test_matches "$($BINARY -s heavy "test")" "┗.*┛" "heavy: bottom corners"

test_matches "$($BINARY -s double "test")" "╔.*╗" "double: top corners"
test_matches "$($BINARY -s double "test")" "╚.*╝" "double: bottom corners"

test_contains "$($BINARY -s dotted "test")" "╌" "dotted: horizontal"
test_contains "$($BINARY -s dotted "test")" "╎" "dotted: vertical"

test_contains "$($BINARY -s dashed "test")" "┄" "dashed: horizontal"
test_contains "$($BINARY -s dashed "test")" "┆" "dashed: vertical"

test_contains "$($BINARY -s ascii "test")" "+" "ascii: corners"
test_contains "$($BINARY -s ascii "test")" "|" "ascii: vertical"

test_contains "$($BINARY -s star "test")" "****" "star: border"

test_contains "$($BINARY -s hash "test")" "####" "hash: border"

test_contains "$($BINARY -s diamond "test")" "◆" "diamond: corners"

test_contains "$($BINARY -s bubble "test")" "⸢" "bubble: corners"

test_contains "$($BINARY -s curly "test")" "╭" "curly: top corner"

echo ""
echo "=== Padding ==="

output=$($BINARY -p 0 "test")
lines=$(echo "$output" | wc -l | tr -d ' ')
if [ "$lines" = "3" ]; then
    pass "padding 0: 3 lines"
else
    fail "padding 0: 3 lines" "Got $lines lines"
fi

output=$($BINARY -p 1 "test")
lines=$(echo "$output" | wc -l | tr -d ' ')
if [ "$lines" = "5" ]; then
    pass "padding 1: 5 lines"
else
    fail "padding 1: 5 lines" "Got $lines lines"
fi

output=$($BINARY -p 2 "test")
lines=$(echo "$output" | wc -l | tr -d ' ')
if [ "$lines" = "7" ]; then
    pass "padding 2: 7 lines"
else
    fail "padding 2: 7 lines" "Got $lines lines"
fi

echo ""
echo "=== Margin ==="

output=$($BINARY -m 0 "test")
if printf '%s' "$output" | head -1 | grep -qE "^┌"; then
    pass "margin 0: starts with corner"
else
    fail "margin 0: starts with corner"
fi

output=$($BINARY -m 2 "test")
if printf '%s' "$output" | head -1 | grep -qE "^  ┌"; then
    pass "margin 2: starts with 2 spaces"
else
    fail "margin 2: starts with 2 spaces"
fi

echo ""
echo "=== Pipe input ==="

output=$(echo "piped" | $BINARY)
if printf '%s' "$output" | grep -qF "piped"; then
    pass "pipe: contains piped text"
else
    fail "pipe: contains piped text"
fi

output=$(echo "" | $BINARY)
if printf '%s' "$output" | grep -qF "Hello from boxsay!"; then
    pass "pipe: empty uses default"
else
    fail "pipe: empty uses default"
fi

echo ""
echo "=== Multiline ==="

output=$(printf 'line1\nline2' | $BINARY)
count=$(printf '%s' "$output" | grep -c "line" || true)
if [ "$count" = "2" ]; then
    pass "multiline: 2 lines in box"
else
    fail "multiline: 2 lines in box" "Got $count"
fi

echo ""
echo "=== Options ==="

help_output=$($BINARY --help 2>&1)
test_contains "$help_output" "--style" "help: --style"
test_contains "$help_output" "--padding" "help: --padding"
test_contains "$help_output" "--margin" "help: --margin"

list_output=$($BINARY --list 2>&1)
test_contains "$list_output" "classic" "list: classic"
test_contains "$list_output" "rounded" "list: rounded"

version_output=$($BINARY --version 2>&1)
test_contains "$version_output" "boxsay" "version: boxsay"

echo ""
echo "=== Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "✓ All tests passed!"
    exit 0
else
    echo ""
    echo "✗ Some tests failed"
    exit 1
fi
