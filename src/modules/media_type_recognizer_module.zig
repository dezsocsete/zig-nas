const std = @import("std");
const ty = @import("../enums/media_types.zig");
const strUtil = @import("../utils/string_util.zig");
const utils = @import("../utils/core_utils.zig");

const MediaTypes = ty.MediaTypes;

pub fn recognizeMediaType(entryName: []const u8) !MediaTypes {
    std.debug.print("Recognizing media type for: {s}", .{entryName});

    const isTvShow = try strUtil.regexMatch(entryName, ".*S\\d{1,2}.*");
    std.debug.print("{s} is TvShow: {}", .{ entryName, isTvShow });
    if (isTvShow) {
        return MediaTypes.TvShow;
    } else {
        return MediaTypes.Movie;
    }
}

pub fn getMediaDestinationPath(entryName: []const u8, path: []const u8) ![]const u8 {
    const recognizedMediaType = try recognizeMediaType(entryName);
    switch (recognizedMediaType) {
        MediaTypes.TvShow => {
            return try utils.createPath(path, entryName);
        },
        MediaTypes.Movie => {
            return try utils.createPath(path, entryName);
        },
        else => return try utils.createPath(path, entryName),
    }
}
