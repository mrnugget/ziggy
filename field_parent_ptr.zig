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
