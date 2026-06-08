const std = @import("std");
const httpz = @import("httpz");

pub fn main(init: std.process.Init) !void {
    var server = try httpz.Server(void).init(init.io, std.heap.smp_allocator, .{ .address = .all(8083) }, {});
    defer server.deinit();

    var router = try server.router(.{});
    router.get("/hello", hello, .{});

    try server.listen();
}

fn hello(_: *httpz.Request, res: *httpz.Response) !void {
    res.body = "Hello World";
}
