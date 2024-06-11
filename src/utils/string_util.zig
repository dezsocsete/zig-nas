const std = @import("std");
const Regex = @import("../packages/zig-regex/src/regex.zig").Regex;
const heap = std.heap;
const mem = std.mem;

pub fn stringContains(text: []const u8, match: []const u8) bool {
    return mem.containsAtLeast(u8, text, 1, match);
}

pub fn stringContainsAny(text: []const u8, matches: []const []const u8) bool {
    for (matches) |match| {
        if (stringContains(text, match)) {
            return true;
        }
    }
    return false;
}

pub fn toLower(text: []const u8) ![]const u8 {
    const allocator = heap.page_allocator;
    const buffer = try allocator.alloc(u8, text.len);
    var i: u8 = 0;
    for (text) |char| {
        buffer[i] = std.ascii.toLower(char);
        i += 1;
    }
    return buffer;
}

pub fn concat(args: []const []const u8) anyerror![]const u8 {
    const allocator = heap.page_allocator;
    return try mem.concat(allocator, u8, args);
}

pub fn regexMatch(text: []const u8, pattern: []const u8) !bool {
    const allocator = heap.page_allocator;

    var regex = try Regex.compile(allocator, pattern);
    defer regex.deinit();
    return try regex.match(text);
}

test "toLower" {
    const text = "HelLo";
    const match = "hello";
    const lowered = try toLower(text);
    std.debug.print("lowered: {s}\n", .{lowered});
    std.debug.print("match: {s}\n", .{match});
    const result = mem.eql(u8, lowered, match);
    try std.testing.expect(result);
}
