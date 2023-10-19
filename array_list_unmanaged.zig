const std = @import("std");

test "zig std array list unmanaged" {
    const gpa = std.testing.allocator;

    var arr: std.ArrayListUnmanaged(u8) = .{};
    defer arr.deinit(gpa);

    try arr.append(gpa, 99);
    try arr.append(gpa, 55);
    try arr.append(gpa, 33);

    const len = arr.items.len;
    try std.testing.expectEqual(len, 3);

    std.debug.print("\n", .{});
    for (arr.items) |item| {
        std.debug.print("item: {}\n", .{item});
    }

    const last = arr.items[arr.items.len - 1];
    std.debug.print("last: {}\n", .{last});

    const elem_idx = for (arr.items, 0..) |person, i| {
        if (person == 55) break i;
    } else null;

    std.debug.print("elem idx: {?}\n", .{elem_idx});
}
