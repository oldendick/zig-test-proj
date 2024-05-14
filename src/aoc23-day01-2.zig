const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    const items = [_][]const u8{
        "0",    "1",   "2",   "3",     "4",    "5",    "6",   "7",     "8",     "9",
        "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    };
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("../input3", .{});
    defer file.close();

    // Wrap the file reader in a buffered reader.
    // Since it's usually faster to read a bunch of bytes at once.
    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();
    var sum: u64 = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        //print("{s}\n", .{line.items});
        var found: bool = false;
        var min: usize = 0;
        var max: usize = 0;
        var tens: usize = undefined;
        var ones: usize = undefined;
        for (items, 0..) |n, i| {
            const fi: usize = std.mem.indexOf(u8, line.items, n) orelse continue;
            const li: usize = std.mem.lastIndexOf(u8, line.items, n) orelse continue;
            if (!found) {
                found = true;
                min = fi;
                max = li;
                tens = i % 10;
                ones = i % 10;
            }
            if (fi < min) {
                min = fi;
                tens = i % 10;
            }
            if (li > max) {
                max = li;
                ones = i % 10;
            }
            //print("needle: {s} ; first index: {d} ; last index: {d}\n", .{ n, fi, li });
        }
        sum += tens * 10 + ones;
        //print("min: {d} ; max: {d} ; tens: {d} ; ones: {d}; sum: {d}\n", .{ min, max, tens, ones, sum });
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => return err, // Propagate error
    }
    print("{d}\n", .{sum});
}
