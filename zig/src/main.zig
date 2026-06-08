const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const addr = try std.Io.net.IpAddress.parseLiteral("0.0.0.0:8083");
    var server = addr.listen(init.io, .{}) catch |err| {
        if (err == error.AddressInUse)
            std.debug.print("error: failed to bind port 8083 (already in use?)\n", .{});
        return err;
    };
    defer server.deinit(init.io);

    while (true) {
        const stream = try server.accept(init.io);
        handle(init.io, stream) catch {};
    }
}

fn handle(io: std.Io, stream: std.Io.net.Stream) !void {
    defer stream.close(io);

    var read_buf: [4096]u8 = undefined;
    var write_buf: [4096]u8 = undefined;
    var reader = stream.reader(io, &read_buf);
    var writer = stream.writer(io, &write_buf);

    var http = std.http.Server.init(&reader.interface, &writer.interface);
    var req = try http.receiveHead();

    if (std.mem.eql(u8, req.head.target, "/hello")) {
        try req.respond("Hello World", .{ .keep_alive = false });
    } else {
        try req.respond("", .{ .status = .not_found, .keep_alive = false });
    }
}
