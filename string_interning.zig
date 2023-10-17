const std = @import("std");

const StringTable: type = std.HashMapUnmanaged(u32, void, std.hash_map.StringIndexContext, std.hash_map.default_max_load_percentage);

test "zig std string interning" {
    const gpa = std.testing.allocator;

    // These two are exactly like `string_table`/`string_bytes` in Zig's
    // src/AstGen.zig
    var string_table: StringTable = .{};
    defer string_table.deinit(gpa);

    var string_bytes: std.ArrayListUnmanaged(u8) = .{};
    defer string_bytes.deinit(gpa);

    const tests = [_]struct {
        string: []const u8,
        internedAt: u32,
    }{
        .{ .string = "hello world", .internedAt = 0 },
        .{ .string = "foobar", .internedAt = 12 },
        .{ .string = "hello world", .internedAt = 0 },
        .{ .string = "barfoo", .internedAt = 19 },
        .{ .string = "foobar", .internedAt = 12 },
    };

    inline for (tests) |case| {
        const res = try internString(&string_bytes, &string_table, gpa, case.string);
        try std.testing.expectEqual(res, case.internedAt);
    }
}

fn internString(string_bytes: *std.ArrayListUnmanaged(u8), string_table: *StringTable, gpa: std.mem.Allocator, string: []const u8) !u32 {
    // Get index of `string` once it's added to `string_bytes`.
    const str_index: u32 = @intCast(string_bytes.items.len);

    // Optimistically add `string` to `string_bytes`.
    try string_bytes.appendSlice(gpa, string);

    // Now check the StringTable whether we already have it interned.
    const gop = try string_table.getOrPutContextAdapted(gpa, string, std.hash_map.StringIndexAdapter{
        .bytes = string_bytes,
    }, std.hash_map.StringIndexContext{
        .bytes = string_bytes,
    });

    if (gop.found_existing) {
        // If has already been added to `string_bytes`, remove the
        // newly-appended `string` again.
        string_bytes.shrinkRetainingCapacity(str_index);
        return gop.key_ptr.*;
    } else {
        // If not, update the entry to point to the index in string_bytes.
        gop.key_ptr.* = str_index;
        // Add null byte at end.
        try string_bytes.append(gpa, 0);
        return str_index;
    }
}
