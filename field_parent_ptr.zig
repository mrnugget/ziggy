const std = @import("std");
const builtin = @import("builtin");

const MyStep = struct {
    coolness: u8 = 10,

    makeFn: *const fn (*MyStep) void,

    pub fn make(my_step: *MyStep) void {
        // some custom logic that happens for every step
        my_step.makeFn(my_step);
    }
};

const MyStepImpl = struct {
    my_step: MyStep,
    my_swag: u8 = 20,

    pub fn make(my_step: *MyStep) void {
        std.log.err("{any}", .{@fieldParentPtr(MyStepImpl, "my_step", my_step)});
    }
};

const MyStepImpl2 = struct {
    my_step: MyStep,
    my_swag_better: u8 = 40,

    pub fn make(my_step: *MyStep) void {
        std.log.err("{any}", .{@fieldParentPtr(MyStepImpl, "my_step", my_step)});
    }
};

test "foobar" {
    var impl = MyStepImpl2{ .my_step = MyStep{ .coolness = 25, .makeFn = MyStepImpl2.make }, .my_swag_better = 75 };

    impl.my_step.make();

    // MyStepImpl.make(&impl.my_step);
}

const Container = union(enum) {
    none: void,

    left: *Child,
    right: *Child,

    fn parent(self: Container) ?*Parent {
        return switch (self) {
            .none => null,
            .left => |ptr| @fieldParentPtr(Parent, "left", ptr),
            .right => |ptr| @fieldParentPtr(Parent, "right", ptr),
        };
    }
};

const Child = struct {
    name: []const u8,
    container: Container = .{ .none = {} },

    fn parentName(self: *Child) ?[]const u8 {
        const parent = self.container.parent() orelse return null;
        return parent.name;
    }
};

const Parent = struct {
    name: []const u8,

    left: Child,
    right: Child,
};

test "child and parent" {
    const expect = std.testing.expect;
    var alloc = std.testing.allocator;

    var parent = try alloc.create(Parent);
    defer alloc.destroy(parent);

    parent.name = "bob";

    var child1 = Child{ .name = "child1" };
    parent.left = child1;
    child1.container = .{ .left = &parent.left };

    var child2 = Child{ .name = "child2" };
    parent.right = child2;
    child2.container = .{ .right = &parent.right };

    const name1 = child1.parentName() orelse unreachable;
    try expect(std.mem.eql(u8, name1, "bob"));
    const name2 = child2.parentName() orelse unreachable;
    try expect(std.mem.eql(u8, name2, "bob"));
}
