const std = @import("std");

test "errors" {
    try std.testing.expectError(error.ItsTooBig, returnsErr(10, 2));

    const res = try returnsErr(13, 2);
    try std.testing.expectEqual(@as(u8, 15), res);
}

fn returnsErr(a: u8, b: u8) !u8 {
    return if (a > 12) a + b else error.ItsTooBig;
}
