const Parent = struct {
    name: []const u8,

    left: Child,
    right: Child,
};

const Child = struct {
    name: []const u8,

    position: enum {
        left,
        right,
    },

    fn parentName(self: *Child) []const u8 {
        const parent = switch (self.position) {
            .left => @fieldParentPtr(Parent, "left", self),
            .right => @fieldParentPtr(Parent, "right", self),
        };

        return parent.name;
    }
};

test "child and parent" {
    const std = @import("std");

    var parent = Parent{
        .name = "bob",
        .left = Child{ .name = "child1", .position = .left },
        .right = Child{ .name = "child2", .position = .right },
    };

    const child1 = &parent.left;
    const child2 = &parent.right;

    try std.testing.expect(std.mem.eql(u8, child1.parentName(), "bob"));
    try std.testing.expect(std.mem.eql(u8, child2.parentName(), "bob"));
}
