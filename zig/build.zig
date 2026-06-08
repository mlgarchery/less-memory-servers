const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    // To choose between https://ziglang.org/documentation/0.16.0/#toc-Build-Mode:
    const optimize = b.option(std.builtin.OptimizeMode, "optimize", "Optimization level") orelse .ReleaseSafe;

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = true,
        .single_threaded = true,
    });

    const exe = b.addExecutable(.{
        .name = "zig-server",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);
}
