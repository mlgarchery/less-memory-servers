const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const addr = try net.IpAddress.parse("0.0.0.0", 8083);

    var server = try addr.listen(io, .{});
    defer server.deinit(io);

    while (true) {
        var conn = try server.accept(io);
        defer conn.close(io);

        var read_buf: [1024]u8 = undefined;
        var reader = conn.reader(io, &read_buf);
        var writer = conn.writer(io, &.{});

        const line = reader.interface.takeDelimiterExclusive('\n') catch continue;

        const response =
            if (std.mem.startsWith(u8, line, "GET /hello "))
                "HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"
            else
                "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n";

        try writer.interface.writeAll(response);
    }
}
