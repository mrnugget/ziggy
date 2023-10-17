const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize,
    };

    pub const keywords = std.ComptimeStringMap(Tag, .{
        .{ "fn", .keyword_fn },
        .{ "for", .keyword_for },
        .{ "if", .keyword_if },
        .{ "var", .keyword_var },
    });

    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }

    pub const Tag = enum {
        eof,
        invalid,
        identifier,
        string_literal,
        number_literal,
        equal,
        l_paren,
        r_paren,
        l_bracket,
        r_bracket,
        semicolon,
        plus,
        minus,
        keyword_fn,
        keyword_for,
        keyword_if,
        keyword_var,
    };
};

pub const Tokenizer = struct {
    buffer: [:0]const u8,
    index: usize,

    pub fn init(buffer: [:0]const u8) Tokenizer {
        return Tokenizer{
            .buffer = buffer,
            .index = 0,
        };
    }

    const State = enum {
        start,
        identifier,
        string_literal,
        int,
    };

    pub fn next(self: *Tokenizer) Token {
        var state: State = .start;
        var result = Token{
            .tag = .eof,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
        };

        while (true) : (self.index += 1) {
            const c = self.buffer[self.index];
            switch (state) {
                .start => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            result.tag = .invalid;
                            result.loc.start = self.index;
                            self.index += 1;
                            result.loc.end = self.index;
                            return result;
                        }
                        break;
                    },
                    ' ', '\n', '\t', '\r' => {
                        result.loc.start = self.index + 1;
                    },
                    '"' => {
                        state = .string_literal;
                        result.tag = .string_literal;
                    },
                    'a'...'z', 'A'...'Z', '_' => {
                        state = .identifier;
                        result.tag = .identifier;
                    },
                    '=' => {
                        result.tag = .equal;
                        self.index += 1;
                        break;
                    },
                    '(' => {
                        result.tag = .l_paren;
                        self.index += 1;
                        break;
                    },
                    ')' => {
                        result.tag = .r_paren;
                        self.index += 1;
                        break;
                    },
                    '[' => {
                        result.tag = .l_bracket;
                        self.index += 1;
                        break;
                    },
                    ']' => {
                        result.tag = .r_bracket;
                        self.index += 1;
                        break;
                    },
                    ';' => {
                        result.tag = .semicolon;
                        self.index += 1;
                        break;
                    },
                    '+' => {
                        result.tag = .plus;
                        self.index += 1;
                        break;
                    },
                    '-' => {
                        result.tag = .minus;
                        self.index += 1;
                        break;
                    },
                    '0'...'9' => {
                        state = .int;
                        result.tag = .number_literal;
                    },
                    else => {
                        result.tag = .invalid;
                        result.loc.end = self.index;
                        self.index += 1;
                        return result;
                    },
                },

                .identifier => switch (c) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => {},
                    else => {
                        if (Token.getKeyword(self.buffer[result.loc.start..self.index])) |tag| {
                            result.tag = tag;
                        }
                        break;
                    },
                },

                .string_literal => switch (c) {
                    '"' => {
                        self.index += 1;
                        break;
                    },
                    0 => {
                        if (self.index == self.buffer.len) {
                            result.tag = .invalid;
                            break;
                        }
                    },
                    else => {},
                },

                .int => switch (c) {
                    '_', 'a'...'d', 'f'...'o', 'q'...'z', 'A'...'D', 'F'...'O', 'Q'...'Z', '0'...'9' => {},
                    else => break,
                },
            }
        }

        if (result.tag == .eof) {
            result.loc.start = self.index;
        }

        result.loc.end = self.index;
        return result;
    }
};

test "keywords" {
    try testTokenize("if var for", &.{ .keyword_if, .keyword_var, .keyword_for });
}

test "identifiers" {
    try testTokenize("horse foobar barfoo if", &.{ .identifier, .identifier, .identifier });
}

test "operators" {
    try testTokenize("+ - =", &.{ .plus, .minus, .equal });
}

test "invalid" {
    try testTokenize("/\\", &.{ .invalid, .invalid });
}

test "string literals" {
    const source = "\"foobar\"";
    var tokenizer = Tokenizer.init(source);

    const token = tokenizer.next();
    try std.testing.expectEqual(@as(Token.Tag, .string_literal), token.tag);
    try std.testing.expectEqual(@as(usize, 0), token.loc.start);
    try std.testing.expectEqual(@as(usize, 8), token.loc.end);
}

test "integer literals" {
    try testTokenize("1 2 3 4567 89101112", &.{ .number_literal, .number_literal, .number_literal, .number_literal, .number_literal });
}

fn testTokenize(source: [:0]const u8, expected_token_tags: []const Token.Tag) !void {
    var tokenizer = Tokenizer.init(source);
    for (expected_token_tags) |expected_token_tag| {
        const token = tokenizer.next();
        try std.testing.expectEqual(expected_token_tag, token.tag);
    }
    const last_token = tokenizer.next();
    try std.testing.expectEqual(Token.Tag.eof, last_token.tag);
    try std.testing.expectEqual(source.len, last_token.loc.start);
    try std.testing.expectEqual(source.len, last_token.loc.end);
}
