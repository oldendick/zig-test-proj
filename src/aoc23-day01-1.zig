const std = @import("std");

fn parse_stdin_looking_for_eol() !u32 {
    const stdin_file = std.io.getStdIn().reader();
    const newline: []const u8 = "\n";

    var tens: u8 = 0;
    var ones: u8 = 0;
    var sum: u32 = 0;
    var digit_found = false;
    while (true) {
        const byte: u8 = stdin_file.readByte() catch |err| switch (err) {
            error.EndOfStream => return sum,
            else => return err,
        };

        const x = [_]u8{byte}; // cast
        if (std.ascii.isDigit(byte)) {
            if (!digit_found) {
                digit_found = true;
                tens = try std.fmt.parseUnsigned(u8, &x, 10);
                ones = try std.fmt.parseUnsigned(u8, &x, 10);
            } else {
                ones = try std.fmt.parseUnsigned(u8, &x, 10);
            }
        }
        if (std.mem.eql(u8, &x, newline)) {
            const calibration = tens * 10 + ones;
            sum += calibration;
            digit_found = false;
            tens = 0;
            ones = 0;
        }
    }
}

pub fn main() !void {
    const ans: u32 = try parse_stdin_looking_for_eol();
    std.debug.print("{d}\n", .{ans});
}
