const std = @import("std");

test "using a hashmap as a string set" {
    const alloc = std.testing.allocator;

    // ╭─────────────╮
    // │ Preparation │
    // ╰─────────────╯
    // Create HashMap and underlying ArrayList in which we'll store strings.
    var map: std.HashMapUnmanaged(u32, void, std.hash_map.StringIndexContext, std.hash_map.default_max_load_percentage) = .{};
    defer map.deinit(alloc);

    var arr: std.ArrayListUnmanaged(u8) = .{};
    defer arr.deinit(alloc);

    // We need these two to use our `map` in combination with `arr`.
    const key_ctx = std.hash_map.StringIndexAdapter{ .bytes = &arr };
    const ctx = std.hash_map.StringIndexContext{ .bytes = &arr };

    //
    // ╭─────────────────────────╮
    // │ Add key1 to the HashMap │
    // ╰─────────────────────────╯
    // Create HashMap and underlying ArrayList in which we'll store strings.
    // Add key1 to `arr`
    const key1: []const u8 = "this is key 1";
    var str_index: u32 = @intCast(arr.items.len);
    try arr.appendSlice(alloc, key1);

    // Now check the StringTable whether we already have it interned.
    const gop1 = try map.getOrPutContextAdapted(alloc, key1, key_ctx, ctx);
    // We don't, duh
    try std.testing.expect(!gop1.found_existing);
    // Now update the entry to point to the index in string_bytes.
    // NOTE: This updates the **key**, not the value!
    gop1.key_ptr.* = str_index;
    // Add null byte at end.
    try arr.append(alloc, 0);

    // Now it's in the hashset
    const gop2 = try map.getOrPutContextAdapted(alloc, key1, key_ctx, ctx);
    try std.testing.expect(gop2.found_existing);

    //
    // ╭─────────────────────────╮
    // │ Add key2 to the HashMap │
    // ╰─────────────────────────╯
    const key2: []const u8 = "look, another key";
    str_index = @intCast(arr.items.len);
    try arr.appendSlice(alloc, key2);

    const gop3 = try map.getOrPutContextAdapted(alloc, key2, key_ctx, ctx);
    try std.testing.expect(!gop3.found_existing);

    // Update index
    gop3.key_ptr.* = str_index;
    // Add null byte at end.
    try arr.append(alloc, 0);

    const gop4 = try map.getOrPutContextAdapted(alloc, key2, key_ctx, ctx);
    try std.testing.expect(gop4.found_existing);

    // ╭───────────╮
    // │ Tadaaaaa! │
    // ╰───────────╯
    // Now both keys are added and point to the index of the strings in `arr`.
    // Printing the keys...
    var keyIter = map.keyIterator();
    while (keyIter.next()) |entry| {
        std.debug.print("key: {}\n", .{entry.*});
    }

    // ... gives us:
    // ╭─────────╮
    // │ key: 0  │
    // │ key: 14 │
    // ╰─────────╯
    // which are the indexes of both keys in `arr`.
}
