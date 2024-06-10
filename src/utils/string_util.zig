const std = @import("std");

pub fn stringContains(text: []const u8, match: []const u8) bool {
    return std.mem.containsAtLeast(u8, text, 1, match);
}

pub fn concat(args: []const []const u8) anyerror![]const u8 {
    const allocator = std.heap.page_allocator;
    return try std.mem.concat(allocator, u8, args);
}
