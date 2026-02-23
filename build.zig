const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = b.option(
        []const u8,
        "version",
        "version string (default: from git tag or dev)",
    ) orelse getVersion(b) orelse "dev";

    const mod = b.addModule("boxsay", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "boxsay",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "boxsay", .module = mod },
            },
        }),
    });

    const version_opt = b.addOptions();
    version_opt.addOption([]const u8, "version", version);
    exe.root_module.addOptions("build_options", version_opt);

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}

fn getVersion(b: *std.Build) ?[]const u8 {
    const result = std.process.Child.run(.{
        .allocator = b.allocator,
        .argv = &.{ "git", "describe", "--tags", "--always", "--dirty" },
    }) catch return null;
    defer b.allocator.free(result.stderr);
    defer b.allocator.free(result.stdout);

    if (result.term.Exited != 0) return null;

    const trimmed = std.mem.trim(u8, result.stdout, " \t\r\n");

    if (std.mem.startsWith(u8, trimmed, "v")) {
        return b.dupe(trimmed[1..]);
    }
    return b.dupe(trimmed);
}
