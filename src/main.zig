const std = @import("std");
const boxsay = @import("boxsay");
const build_options = @import("build_options");

fn printUsage() void {
    std.debug.print(
        \\boxsay - Wrap text in a box
        \\
        \\Usage:
        \\  boxsay [options] [text]
        \\  echo "text" | boxsay
        \\
        \\Options:
        \\  -s, --style <name>    Box style (default: classic)
        \\  -p, --padding <n>     Inner padding (default: 1)
        \\  -m, --margin <n>      Outer margin (default: 0)
        \\  -l, --list            List all available styles
        \\  -h, --help            Show this help message
        \\  -v, --version         Show version number
        \\
        \\Examples:
        \\  boxsay "Hello, World!"
        \\  boxsay -s rounded "Rounded corners"
        \\  boxsay -s heavy -p 2 "Bold box"
        \\  echo "Pipe input" | boxsay -s double
        \\
    , .{});
}

fn printVersion() void {
    std.debug.print("boxsay {s}\n", .{build_options.version});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var style_name: []const u8 = "classic";
    var padding: usize = 1;
    var margin: usize = 0;
    var text_parts = std.ArrayList([]const u8).empty;
    defer text_parts.deinit(allocator);

    var i: usize = 1;
    while (i < args.len) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            printUsage();
            return;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            printVersion();
            return;
        } else if (std.mem.eql(u8, arg, "-l") or std.mem.eql(u8, arg, "--list")) {
            boxsay.listStyles();
            return;
        } else if (std.mem.eql(u8, arg, "-s") or std.mem.eql(u8, arg, "--style")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: --style requires a style name\n", .{});
                return;
            }
            style_name = args[i];
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--padding")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: --padding requires a number\n", .{});
                return;
            }
            padding = std.fmt.parseInt(usize, args[i], 10) catch {
                std.debug.print("Error: padding must be a number\n", .{});
                return;
            };
        } else if (std.mem.eql(u8, arg, "-m") or std.mem.eql(u8, arg, "--margin")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: --margin requires a number\n", .{});
                return;
            }
            margin = std.fmt.parseInt(usize, args[i], 10) catch {
                std.debug.print("Error: margin must be a number\n", .{});
                return;
            };
        } else if (std.mem.startsWith(u8, arg, "-")) {
            std.debug.print("Error: Unknown option '{s}'\n", .{arg});
            printUsage();
            return;
        } else {
            try text_parts.append(allocator, arg);
        }
        i += 1;
    }

    const style = boxsay.getStyle(style_name) orelse {
        std.debug.print("Error: Unknown style '{s}'\n", .{style_name});
        std.debug.print("Use --list to see available styles\n", .{});
        return;
    };

    var need_free_text = false;
    const text: []const u8 = blk: {
        if (text_parts.items.len > 0) {
            need_free_text = true;
            break :blk try std.mem.join(allocator, " ", text_parts.items);
        } else {
            const stdin_file = std.fs.File.stdin();
            var buf: [4096]u8 = undefined;
            const n = stdin_file.read(&buf) catch {
                break :blk "Hello from boxsay!";
            };
            if (n == 0) {
                break :blk "Hello from boxsay!";
            }
            const trimmed = std.mem.trim(u8, buf[0..n], " \t\n\r");
            if (trimmed.len == 0) {
                break :blk "Hello from boxsay!";
            }
            need_free_text = true;
            break :blk try allocator.dupe(u8, trimmed);
        }
    };
    defer if (need_free_text) allocator.free(text);

    var stdout_buf: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    const box = try boxsay.drawBox(allocator, text, .{
        .style = style,
        .padding = padding,
        .margin = margin,
    });
    defer allocator.free(box);

    try stdout.writeAll(box);
    try stdout.flush();
}
