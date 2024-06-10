const std = @import("std");
const ty = @import("../enums/media_types.zig");
const strUtil = @import("../utils/string_util.zig");

const MediaTypes = ty.MediaTypes;

pub fn recognizeMediaType(path: []const u8) MediaTypes {
    std.debug.print("Recognizing media type for: {s}", .{path});
    return MediaTypes.Movie;
}
