const std = @import("std");

const Person = union(enum) {
    name: []const u8,
    pet: []const u8,

    empty,

    const Self = @This();

    pub fn is_empty(self: Self) bool {
        return self == .empty;
    }
};

test "person enum" {
    const foo: Person = .{ .name = "foobar" };
    const bar: Person = .{ .pet = "barfoo" };

    std.debug.print("foo: {}, bar: {}\n", .{ foo, bar });

    const e: Person = .empty;
    std.debug.print("is empty: {}\n", .{e == Person.empty});

    const list = [_]Person{ foo, bar, e };

    for (list, 0..) |person, i| {
        std.debug.print("person {} is empty: {}\n", .{ i, person.is_empty() });
        std.debug.print("person {} is empty: {}\n", .{ i, person == .empty });
    }
}
