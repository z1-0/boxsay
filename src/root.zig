const std = @import("std");

pub const BoxStyle = struct {
    name: []const u8,
    desc: []const u8,
    tl: []const u8,
    tr: []const u8,
    bl: []const u8,
    br: []const u8,
    h: []const u8,
    v: []const u8,
};

pub const styles = [_]BoxStyle{
    .{
        .name = "classic",
        .desc = "Classic square corners",
        .tl = "┌",
        .tr = "┐",
        .bl = "└",
        .br = "┘",
        .h = "─",
        .v = "│",
    },
    .{
        .name = "rounded",
        .desc = "Rounded corners",
        .tl = "╭",
        .tr = "╮",
        .bl = "╰",
        .br = "╯",
        .h = "─",
        .v = "│",
    },
    .{
        .name = "heavy",
        .desc = "Heavy/bold lines",
        .tl = "┏",
        .tr = "┓",
        .bl = "┗",
        .br = "┛",
        .h = "━",
        .v = "┃",
    },
    .{
        .name = "double",
        .desc = "Double lines",
        .tl = "╔",
        .tr = "╗",
        .bl = "╚",
        .br = "╝",
        .h = "═",
        .v = "║",
    },
    .{
        .name = "dotted",
        .desc = "Dotted lines",
        .tl = "┌",
        .tr = "┐",
        .bl = "└",
        .br = "┘",
        .h = "╌",
        .v = "╎",
    },
    .{
        .name = "dashed",
        .desc = "Dashed lines",
        .tl = "┌",
        .tr = "┐",
        .bl = "└",
        .br = "┘",
        .h = "┄",
        .v = "┆",
    },
    .{
        .name = "ascii",
        .desc = "ASCII only",
        .tl = "+",
        .tr = "+",
        .bl = "+",
        .br = "+",
        .h = "-",
        .v = "|",
    },
    .{
        .name = "star",
        .desc = "Star characters",
        .tl = "*",
        .tr = "*",
        .bl = "*",
        .br = "*",
        .h = "*",
        .v = "*",
    },
    .{
        .name = "hash",
        .desc = "Hash/pound characters",
        .tl = "#",
        .tr = "#",
        .bl = "#",
        .br = "#",
        .h = "#",
        .v = "#",
    },
    .{
        .name = "diamond",
        .desc = "Diamond corners",
        .tl = "◆",
        .tr = "◆",
        .bl = "◆",
        .br = "◆",
        .h = "─",
        .v = "│",
    },
    .{
        .name = "bubble",
        .desc = "Bubble corners",
        .tl = "⸢",
        .tr = "⸣",
        .bl = "⸤",
        .br = "⸥",
        .h = "─",
        .v = "│",
    },
};

pub fn getStyle(name: []const u8) ?BoxStyle {
    for (styles) |s| {
        if (std.mem.eql(u8, s.name, name)) {
            return s;
        }
    }
    return null;
}

pub fn listStyles() void {
    std.debug.print("Available styles:\n", .{});
    for (styles) |s| {
        std.debug.print("  {s:<10} - {s}\n", .{ s.name, s.desc });
    }
}

pub fn getDisplayWidth(char: []const u8) usize {
    if (char.len == 1) {
        const c = char[0];
        if (c < 0x80) {
            if (c >= 0x20 and c < 0x7F) {
                return 1;
            }
            return 0;
        }
    }

    var cp: u21 = 0;
    if (char.len >= 1 and char[0] & 0x80 == 0) {
        cp = @as(u21, char[0]);
    } else if (char.len >= 2 and char[0] & 0xE0 == 0xC0) {
        cp = (@as(u21, char[0] & 0x1F) << 6) | (@as(u21, char[1] & 0x3F));
    } else if (char.len >= 3 and char[0] & 0xF0 == 0xE0) {
        cp = (@as(u21, char[0] & 0x0F) << 12) | (@as(u21, char[1] & 0x3F) << 6) | (@as(u21, char[2] & 0x3F));
    } else if (char.len >= 4 and char[0] & 0xF8 == 0xF0) {
        cp = (@as(u21, char[0] & 0x07) << 18) | (@as(u21, char[1] & 0x3F) << 12) | (@as(u21, char[2] & 0x3F) << 6) | (@as(u21, char[3] & 0x3F));
    }

    if (cp >= 0x1100 and
        (cp <= 0x115F or
            cp == 0x2329 or cp == 0x232A or
            (cp >= 0x2E80 and cp <= 0x303E and cp != 0x303F) or
            (cp >= 0x3040 and cp <= 0xA4CF) or
            (cp >= 0xAC00 and cp <= 0xD7A3) or
            (cp >= 0xF900 and cp <= 0xFAFF) or
            (cp >= 0xFE10 and cp <= 0xFE1F) or
            (cp >= 0xFE30 and cp <= 0xFE6F) or
            (cp >= 0xFF00 and cp <= 0xFF60) or
            (cp >= 0xFFE0 and cp <= 0xFFE6) or
            (cp >= 0x1F300 and cp <= 0x1F9FF)))
    {
        return 2;
    }

    return 1;
}

pub fn stringDisplayWidth(s: []const u8) usize {
    var width: usize = 0;
    var i: usize = 0;
    while (i < s.len) {
        const c = s[i];
        var char_len: usize = 1;
        if (c & 0x80 == 0) {
            char_len = 1;
        } else if (c & 0xE0 == 0xC0) {
            char_len = 2;
        } else if (c & 0xF0 == 0xE0) {
            char_len = 3;
        } else if (c & 0xF8 == 0xF0) {
            char_len = 4;
        }
        if (i + char_len <= s.len) {
            width += getDisplayWidth(s[i .. i + char_len]);
        }
        i += char_len;
    }
    return width;
}

pub const BoxConfig = struct {
    style: BoxStyle,
    padding: usize,
    margin: usize,
};

pub fn drawBox(allocator: std.mem.Allocator, text: []const u8, config: BoxConfig) ![]u8 {
    var lines = std.ArrayList([]const u8).empty;
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var iter = std.mem.splitScalar(u8, text, '\n');
    while (iter.next()) |line| {
        const owned = try allocator.dupe(u8, line);
        try lines.append(allocator, owned);
    }

    if (lines.items.len == 0) {
        try lines.append(allocator, try allocator.dupe(u8, ""));
    }

    var max_width: usize = 0;
    for (lines.items) |line| {
        const w = stringDisplayWidth(line);
        if (w > max_width) max_width = w;
    }

    const inner_width = max_width + config.padding * 2;

    var result = std.ArrayList(u8).empty;

    for (0..config.margin) |_| {
        try result.append(allocator, ' ');
    }
    try result.appendSlice(allocator, config.style.tl);
    for (0..inner_width) |_| {
        try result.appendSlice(allocator, config.style.h);
    }
    try result.appendSlice(allocator, config.style.tr);
    try result.append(allocator, '\n');

    for (0..config.padding) |_| {
        for (0..config.margin) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, config.style.v);
        for (0..inner_width) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, config.style.v);
        try result.append(allocator, '\n');
    }

    for (lines.items) |line| {
        for (0..config.margin) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, config.style.v);
        for (0..config.padding) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, line);
        const line_width = stringDisplayWidth(line);
        const remaining = inner_width - config.padding - line_width;
        for (0..remaining) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, config.style.v);
        try result.append(allocator, '\n');
    }

    for (0..config.padding) |_| {
        for (0..config.margin) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, config.style.v);
        for (0..inner_width) |_| {
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, config.style.v);
        try result.append(allocator, '\n');
    }

    for (0..config.margin) |_| {
        try result.append(allocator, ' ');
    }
    try result.appendSlice(allocator, config.style.bl);
    for (0..inner_width) |_| {
        try result.appendSlice(allocator, config.style.h);
    }
    try result.appendSlice(allocator, config.style.br);
    try result.append(allocator, '\n');

    return result.toOwnedSlice(allocator);
}
