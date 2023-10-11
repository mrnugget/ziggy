test "zig std tokenizer" {
    const std = @import("std");

    var tok = std.zig.Tokenizer.init("comptime {}");

    try std.testing.expectEqual(tok.next().tag, .keyword_comptime);
    try std.testing.expectEqual(tok.next().tag, .l_brace);
    try std.testing.expectEqual(tok.next().tag, .r_brace);
    try std.testing.expectEqual(tok.next().tag, .eof);
}

test "zig std parser" {
    const std = @import("std");
    const expectEqual = std.testing.expectEqual;

    // Setup allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Parse source code
    const source =
        \\ fn addNums(a: i32, b: i32) i32 {
        \\     return a + b;
        \\ }
    ;
    var ast = try std.zig.Ast.parse(allocator, source, .zig);

    // Check that we don't have parse errors
    try expectEqual(@as(usize, 0), ast.errors.len);
    try expectEqual(@as(usize, 11), ast.nodes.len);

    // Print the tags of each node
    std.debug.print("\n", .{});
    for (ast.nodes.items(.tag), 0..) |node, i| {
        std.debug.print("nodes[{}].tag: {}\n", .{ i, node });
    }

    // Print the data of each node
    for (ast.nodes.items(.data), 0..) |node, i| {
        std.debug.print("nodes[{}].data: {}\n", .{ i, node });
    }
}
