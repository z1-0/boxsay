# boxsay

[![CI](https://github.com/z1-0/boxsay/actions/workflows/test.yml/badge.svg)](https://github.com/z1-0/boxsay/actions/workflows/test.yml)
[![Release](https://github.com/z1-0/boxsay/actions/workflows/release.yml/badge.svg)](https://github.com/z1-0/boxsay/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A command-line tool that wraps text in decorative boxes, similar to cowsay but with multiple box styles.

## Features

- 12 box styles (classic, rounded, heavy, double, dotted, dashed, ascii, star, hash, diamond, bubble, curly)
- Customizable padding and margin
- Pipe support for chaining commands
- Unicode/CJK character support
- Zero dependencies, single binary

## Installation

### Binary (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/z1-0/boxsay/main/scripts/install.sh | sh
```

Install to a custom location:

```bash
curl -fsSL https://raw.githubusercontent.com/z1-0/boxsay/main/scripts/install.sh | PREFIX=~/.local sh
```

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/z1-0/boxsay/main/scripts/install.sh | sh -s -- uninstall
```

### Build from source

Requires [Zig](https://ziglang.org/) 0.15+

```bash
git clone https://github.com/z1-0/boxsay.git
cd boxsay
zig build -Doptimize=ReleaseFast
cp zig-out/bin/boxsay ~/.local/bin/
```

## Usage

### Basic

```bash
boxsay "Hello, World!"
```

```
┌───────────────┐
│               │
│ Hello, World! │
│               │
└───────────────┘
```

### Styles

```bash
boxsay --list
```

```
Available styles:
  classic    - Classic square corners
  rounded    - Rounded corners
  heavy      - Heavy/bold lines
  double     - Double lines
  dotted     - Dotted lines
  dashed     - Dashed lines
  ascii      - ASCII only
  star       - Star characters
  hash       - Hash/pound characters
  diamond    - Diamond corners
  bubble     - Bubble corners
  curly      - Curly corners
```

Examples:

**classic**
```bash
boxsay -s classic "classic"
```
```
┌─────────┐
│         │
│ classic │
│         │
└─────────┘
```

**rounded**
```bash
boxsay -s rounded "rounded"
```
```
╭─────────╮
│         │
│ rounded │
│         │
╰─────────╯
```

**heavy**
```bash
boxsay -s heavy "heavy"
```
```
┏━━━━━━━┓
┃       ┃
┃ heavy ┃
┃       ┃
┗━━━━━━━┛
```

**double**
```bash
boxsay -s double "double"
```
```
╔════════╗
║        ║
║ double ║
║        ║
╚════════╝
```

**dotted**
```bash
boxsay -s dotted "dotted"
```
```
┌╌╌╌╌╌╌╌╌┐
╎        ╎
╎ dotted ╎
╎        ╎
└╌╌╌╌╌╌╌╌┘
```

**dashed**
```bash
boxsay -s dashed "dashed"
```
```
┌┄┄┄┄┄┄┄┄┐
┆        ┆
┆ dashed ┆
┆        ┆
└┄┄┄┄┄┄┄┄┘
```

**ascii**
```bash
boxsay -s ascii "ascii"
```
```
+--------+
|        |
|  ascii |
|        |
+--------+
```

**star**
```bash
boxsay -s star "star"
```
```
************
*          *
*   star   *
*          *
************
```

**hash**
```bash
boxsay -s hash "hash"
```
```
############
#          #
#   hash   #
#          #
############
```

**diamond**
```bash
boxsay -s diamond "diamond"
```
```
◆───────────◆
│           │
│  diamond  │
│           │
◆───────────◆
```

**bubble**
```bash
boxsay -s bubble "bubble"
```
```
⸢──────────⸣
│          │
│  bubble  │
│          │
⸤──────────⸥
```

**curly**
```bash
boxsay -s curly "curly"
```
```
╭───────────╮
│           │
│   curly   │
│           │
╰───────────╯
```

### Padding & Margin

```bash
boxsay -p 0 "No padding"
```
```
┌──────────┐
│No padding│
└──────────┘
```

```bash
boxsay -m 2 "With margin"
```
```
  ┌───────────────┐
  │               │
  │  With margin  │
  │               │
  └───────────────┘
```

### Pipe input

```bash
echo "From pipe" | boxsay -s double
```
```
╔═════════════╗
║             ║
║  From pipe  ║
║             ║
╚═════════════╝
```

```bash
date | boxsay -s rounded
```
```
╭─────────────────╮
│                 │
│ Mon Feb 23 2026 │
│                 │
╰─────────────────╯
```

### Multiline

```bash
boxsay "Line 1
Line 2
Line 3"
```
```
┌────────┐
│        │
│ Line 1 │
│ Line 2 │
│ Line 3 │
│        │
└────────┘
```

## Options

```
boxsay [options] [text]

Options:
  -s, --style <name>    Box style (default: classic)
  -p, --padding <n>     Inner padding (default: 1)
  -m, --margin <n>      Outer margin (default: 0)
  -l, --list            List all available styles
  -h, --help            Show help message
  -v, --version         Show version number
```

## [License](LICENSE)
