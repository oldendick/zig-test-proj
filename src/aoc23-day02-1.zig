const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var gpa_game = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_game.deinit();
    const allocator = gpa.allocator();
    const allocator_game = gpa_game.allocator();

    const file = try fs.cwd().openFile("day02-1.txt", .{});
    defer file.close();

    // Wrap the file reader in a buffered reader.
    // Since it's usually faster to read a bunch of bytes at once.
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();
    var line_no: usize = 1;
    var sum: u32 = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) : (line_no += 1) {
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        var game = std.ArrayList([]const u8).init(allocator_game);
        defer game.deinit();

        //print("{d}--{s}\n", .{ line_no, line.items });
        var it = std.mem.tokenizeAny(u8, line.items, " :,;");
        var token = it.next() orelse continue;
        while (true) {
            try game.append(token);
            //print("{s}/", .{token});
            token = it.next() orelse break;
        }

        var valid: bool = true;
        var gameval: u8 = 0;
        for (game.items, 0..) |j, k| {
            if (std.mem.eql(u8, j, "blue")) {
                const cubes: u8 = std.fmt.parseUnsigned(u8, game.items[k - 1], 10) catch continue;
                //print("found {d} blue cubes\n", .{cubes});
                if (cubes > 14) valid = false;
            }
            if (std.mem.eql(u8, j, "red")) {
                const cubes: u8 = std.fmt.parseUnsigned(u8, game.items[k - 1], 10) catch continue;
                //print("found {d} red cubes\n", .{cubes});
                if (cubes > 12) valid = false;
            }
            if (std.mem.eql(u8, j, "green")) {
                const cubes: u8 = std.fmt.parseUnsigned(u8, game.items[k - 1], 10) catch continue;
                //print("found {d} green cubes\n", .{cubes});
                if (cubes > 13) valid = false;
            }
            if (std.mem.eql(u8, j, "Game")) {
                gameval = std.fmt.parseUnsigned(u8, game.items[k + 1], 10) catch continue;
                //print("found game #{d}\n", .{gameval});
            }
        }
        if (valid) {
            sum += gameval;
            //print("game {d} is valid\n", .{gameval});
        }
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => return err, // Propagate error
    }
    print("sum: {d}\n", .{sum});
}
