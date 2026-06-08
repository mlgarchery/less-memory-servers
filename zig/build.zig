const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const httpz_dep = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("httpz", httpz_dep.module("httpz"));

    const exe = b.addExecutable(.{
        .name = "zig-server",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);
}
