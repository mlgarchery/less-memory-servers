const std = @import("std");

const Handler = *const fn (*std.http.Server.Request) anyerror!void;

const Route = struct {
    path: []const u8,
    handler: Handler,
};

var routes: [16]Route = undefined;
var route_count: usize = 0;

fn registerRoute(path: []const u8, handler: Handler) void {
    routes[route_count] = .{ .path = path, .handler = handler };
    route_count += 1;
}

fn dispatch(req: *std.http.Server.Request) anyerror!void {
    const target = req.head.target;
    for (routes[0..route_count]) |route| {
        if (route.path.len == 1 and route.path[0] == '/') {
            if (std.mem.startsWith(u8, target, "/")) {
                return route.handler(req);
            }
        } else if (std.mem.eql(u8, target, route.path)) {
            return route.handler(req);
        }
    }
    try notFound(req);
}

fn hello(req: *std.http.Server.Request) anyerror!void {
    try req.respond("Hello World", .{ .keep_alive = false });
}

fn notFound(req: *std.http.Server.Request) anyerror!void {
    try req.respond("", .{ .status = .not_found, .keep_alive = false });
}

pub fn main(init: std.process.Init) !void {
    registerRoute("/hello", hello);
    registerRoute("/", notFound);

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

    try dispatch(&req);
}
