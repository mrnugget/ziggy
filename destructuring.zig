const std = @import("std");

test "tuple destructuring" {
    foobar(12);
    foobar(1);
}

fn foobar(cond: u8) void {
    const res1: u8, const res2: u8 = if (cond > 5) .{ 1, 2 } else .{ 3, 4 };
    std.debug.print("res1: {d}, res2: {d}\n", .{ res1, res2 });
}
