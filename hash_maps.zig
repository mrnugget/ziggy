const std = @import("std");

test "using a hashmap as a string set" {
    const alloc = std.testing.allocator;

    // Preparation: create HashMap and underlying ArrayList in which we'll
    // store strings.
    var map: std.HashMapUnmanaged(u32, void, std.hash_map.StringIndexContext, std.hash_map.default_max_load_percentage) = .{};
    defer map.deinit(alloc);

    var arr: std.ArrayListUnmanaged(u8) = .{};
    defer arr.deinit(alloc);

    // We need these two to use our `map` in combination with `arr`.
    const key_ctx = std.hash_map.StringIndexAdapter{ .bytes = &arr };
    const ctx = std.hash_map.StringIndexContext{ .bytes = &arr };

    const key1: []const u8 = "this is key 1";
    const key2: []const u8 = "look, another key";

    const str_index: u32 = @intCast(arr.items.len);
    try arr.appendSlice(alloc, key1);

    // Now check the StringTable whether we already have it interned.
    const gop1 = try map.getOrPutContextAdapted(alloc, key1, key_ctx, ctx);
    try std.testing.expect(!gop1.found_existing);
    std.debug.print("gop.key_ptr.*={d}\n", .{gop1.key_ptr.*});

    // If not, update the entry to point to the index in string_bytes.
    gop1.key_ptr.* = str_index;
    // Add null byte at end.
    try arr.append(alloc, 0);

    const gop2 = try map.getOrPutContextAdapted(alloc, key1, key_ctx, ctx);
    try std.testing.expect(gop2.found_existing);
    std.debug.print("gop.key_ptr.*={d}\n", .{gop2.key_ptr.*});

    const gop3 = try map.getOrPutContextAdapted(alloc, key2, key_ctx, ctx);
    try std.testing.expect(!gop3.found_existing);
    std.debug.print("gop.key_ptr.*={d}\n", .{gop3.key_ptr.*});
}
