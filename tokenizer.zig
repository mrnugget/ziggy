test "zig std tokenizer" {
    const std = @import("std");

    var tok = std.zig.Tokenizer.init("comptime {}");

    try std.testing.expectEqual(tok.next().tag, .keyword_comptime);
    try std.testing.expectEqual(tok.next().tag, .l_brace);
    try std.testing.expectEqual(tok.next().tag, .r_brace);
    try std.testing.expectEqual(tok.next().tag, .eof);
}
