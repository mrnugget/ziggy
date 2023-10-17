test "zig std parser" {
    const std = @import("std");
    const expectEqual = std.testing.expectEqual;
    const expect = std.testing.expect;

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

    // fn_decl
    const fn_decl = ast.nodes.get(5);
    std.debug.print("fn_decl.tag: {}\n", .{fn_decl.tag});
    // fn_decl lhs is function prototype:
    const fn_proto_multi = ast.nodes.get(fn_decl.data.lhs);
    std.debug.print("fn_proto_multi.tag: {}\n", .{fn_proto_multi.tag});

    // fn_decl rhs is function body:
    const fn_body = ast.nodes.get(fn_decl.data.rhs);
    std.debug.print("fn_body.tag: {}, fn_body.data: {}\n", .{ fn_body.tag, fn_body.data });

    // fn_body lhs is return statement
    const fn_body_lhs = ast.nodes.get(fn_body.data.lhs);
    std.debug.print("fn_body_lhs.tag: {}, fn_body_lhs.data: {}\n", .{ fn_body_lhs.tag, fn_body_lhs.data });

    // Use this helper function to get the full node
    const fn_proto_multi2 = std.zig.Ast.fnProtoMulti(ast, fn_decl.data.lhs);
    std.debug.print("fn_proto_multi: {}\n", .{fn_proto_multi2});

    // The identifier token is the one after the `fn` keyword
    const ident_token = fn_proto_multi2.ast.fn_token + 1;
    const ident_token_slice = ast.tokenSlice(ident_token);
    std.debug.print("function identifier: {s}\n", .{ident_token_slice});
    try expect(std.mem.eql(u8, ident_token_slice, "addNums"));

    // The source of this whole function:
    const source_from_ast = ast.getNodeSource(5);
    std.debug.print("source: {s}\n", .{source_from_ast});
}
