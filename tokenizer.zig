test "zig std tokenizer" {
    const std = @import("std");

    var tok = std.zig.Tokenizer.init("comptime {}");

    try std.testing.expectEqual(tok.next().tag, .keyword_comptime);
    try std.testing.expectEqual(tok.next().tag, .l_brace);
    try std.testing.expectEqual(tok.next().tag, .r_brace);
    try std.testing.expectEqual(tok.next().tag, .eof);
}

test "zig std tokenizer list" {
    const std = @import("std");

    // Setup allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Setup TokenList
    var tokens = std.zig.Ast.TokenList{};
    defer tokens.deinit(allocator);
    try tokens.ensureTotalCapacity(allocator, 100);

    // Setup tokenizer
    const source = "fn addNums(a: i32, b: i32) i32 { }";
    var tokenizer = std.zig.Tokenizer.init(source);

    // Get all the items into a single list
    while (true) {
        const token = tokenizer.next();
        try tokens.append(allocator, .{
            .tag = token.tag,
            .start = @as(u32, @intCast(token.loc.start)),
        });
        if (token.tag == .eof) break;
    }

    try std.testing.expectEqual(@as(usize, 15), tokens.len);
}
