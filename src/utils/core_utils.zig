const std = @import("std");
const strUtil = @import("string_util.zig");

const fs = std.fs;
const io = std.io;
const mem = std.mem;

pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout = io.getStdOut().writer();
    stdout.print(format, args) catch |err| {
        std.debug.panic("Failed to print to stdout: {}\n", .{err});
    };
}

pub fn createPath(path: []const u8, entryName: []const u8) ![]const u8 {
    const args = &[_][]const u8{ path, "\\", entryName };
    return strUtil.concat(args);
}

pub fn deleteFolder(path: []const u8) !void {
    var splitIterator = mem.split(u8, path, "\\");
    var lastSubPath: ?[]const u8 = null;
    var dirPath: []const u8 = "";
    while (true) {
        const entry = splitIterator.next();
        if (entry == null) {
            break;
        } else {
            if (lastSubPath != null) {
                if (dirPath.len == 0) {
                    dirPath = lastSubPath.?;
                } else {
                    const args = &[_][]const u8{ dirPath, "\\", lastSubPath.? };
                    dirPath = try strUtil.concat(args);
                }
            }
            lastSubPath = entry;
        }
    }
    var outputFolder = try fs.openDirAbsolute(dirPath, .{
        .access_sub_paths = true,
    });
    defer outputFolder.close();
    if (lastSubPath != null) {
        try outputFolder.deleteTree(lastSubPath.?);
    }
}
