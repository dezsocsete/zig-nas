const std = @import("std");
const utils = @import("utils/core_utils.zig");
const strUtil = @import("utils/string_util.zig");
const recognizerModule = @import("modules/media_type_recognizer_module.zig");
const ty = @import("enums/media_types.zig");
const consts = @import("consts/consts.zig");
const fs = std.fs;
const mem = std.mem;

const MediaTypes = ty.MediaTypes;
const input_path = "C:\\git\\zig_nas\\input";
const destination_folder = "C:\\git\\zig_nas\\output";

pub fn main() !void {
    try utils.print("Copying files from {s} to {s}\n", .{ input_path, destination_folder });
    try utils.deleteFolder(destination_folder);
    try fs.makeDirAbsolute(destination_folder);
    try recursiveCopy(input_path, destination_folder);
}

pub fn recursiveCopy(sourcePath: []const u8, destinationPath: []const u8) anyerror!void {
    var folder = try fs.openDirAbsolute(sourcePath, .{
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
    const isInitialFolder = mem.eql(u8, sourcePath, input_path);
    folder.close();
    if (!isInitialFolder) {
        try utils.print("Deleting folder {s}\n", .{sourcePath});
        try utils.deleteFolder(sourcePath);
    }
}

pub fn handleEntry(entry: fs.Dir.Entry, sourcePath: []const u8, destinationPath: []const u8) !void {
    const isFile = entry.kind == .file;
    if (isFile) {
        if (try fileIsUseless(entry.name)) {
            try utils.print("\t\tSkipping useless file: {s}\n", .{entry.name});
            return;
        }
        try handleFile(entry, sourcePath, destinationPath);
    } else {
        if (try folderIsSample(entry.name)) {
            try utils.print("\t\tSkipping sample folder: {s}\n", .{entry.name});
            return;
        }
        try handleFolder(entry, sourcePath, destinationPath);
    }
}

pub fn handleFile(entry: fs.Dir.Entry, path: []const u8, destinationPath: []const u8) !void {
    const entryName = entry.name;
    const entryPath = try utils.createPath(path, entryName);
    const destination = try utils.createPath(destinationPath, entryName);
    try utils.print("\tFile: {s}\n", .{entryName});
    try fs.copyFileAbsolute(entryPath, destination, .{});
    try fs.deleteFileAbsolute(entryPath);
}

pub fn handleFolder(entry: fs.Dir.Entry, path: []const u8, destinationPath: []const u8) !void {
    const entryName = entry.name;
    const nextDestinationPath = try recognizerModule.getMediaDestinationPath(entryName, destinationPath);
    const sourcePath = try utils.createPath(path, entryName);
    try fs.makeDirAbsolute(nextDestinationPath);
    try utils.print("\nChecking folder: {s}{s}\n", .{ nextDestinationPath, entryName });
    try recursiveCopy(sourcePath, nextDestinationPath);
}

pub fn fileIsUseless(entryName: []const u8) !bool {
    const lower = strUtil.toLower(entryName);
    return strUtil.stringContainsAny(try lower, &consts.USELESS_FILE_TEXTS);
}
pub fn folderIsSample(entryName: []const u8) !bool {
    const lower = strUtil.toLower(entryName);
    return strUtil.stringContainsAny(try lower, &consts.USELESS_FOLDER_TEXTS);
}
