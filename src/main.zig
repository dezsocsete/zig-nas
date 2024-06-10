const std = @import("std");
const utils = @import("utils/core_utils.zig");
const strUtil = @import("utils/string_util.zig");

const input_path = "C:\\git\\zig-folder\\input";
const destination_folder = "C:\\git\\zig-folder\\output";

pub fn main() !void {
    try utils.deleteFolder(destination_folder);
    try std.fs.makeDirAbsolute(destination_folder);
    try recursiveCopy(input_path, destination_folder);
}

pub fn recursiveCopy(sourcePath: []const u8, destinationPath: []const u8) anyerror!void {
    var folder = try std.fs.openDirAbsolute(sourcePath, .{
        .iterate = true,
        .access_sub_paths = true,
    });
    var iterator = folder.iterate();
    while (true) {
        const next = try iterator.next();
        if (next == null) break;
        const entry = next.?;
        try handleEntry(entry, sourcePath, destinationPath);
    }
    const isInitialFolder = std.mem.eql(u8, sourcePath, input_path);
    folder.close();
    if (!isInitialFolder) {
        try utils.deleteFolder(sourcePath);
    }
}

pub fn handleEntry(entry: std.fs.Dir.Entry, sourcePath: []const u8, destinationPath: []const u8) !void {
    const isFile = entry.kind == .file;
    if (isFile) {
        try handleFile(entry, sourcePath, destinationPath);
    } else {
        try handleFolder(entry, sourcePath, destinationPath);
    }
}

pub fn handleFile(entry: std.fs.Dir.Entry, path: []const u8, destinationPath: []const u8) !void {
    const entryPath = try createPath(path, entry.name);
    const destination = try createPath(destinationPath, entry.name);
    try utils.print("File: {s}\n", .{entry.name});
    try std.fs.copyFileAbsolute(entryPath, destination, .{});
    try std.fs.deleteFileAbsolute(entryPath);
}

pub fn handleFolder(entry: std.fs.Dir.Entry, path: []const u8, destinationPath: []const u8) !void {
    const entryName = entry.name;
    const nextDestinationPath = try createPath(destinationPath, entryName);
    const sourcePath = try createPath(path, entry.name);
    try std.fs.makeDirAbsolute(nextDestinationPath);
    try utils.print("\nFolder: {s}{s}\n", .{ nextDestinationPath, entry.name });
    try recursiveCopy(sourcePath, nextDestinationPath);
}

pub fn createPath(path: []const u8, entryName: []const u8) ![]const u8 {
    const args = &[_][]const u8{ path, "\\", entryName };
    return strUtil.concat(args);
}
