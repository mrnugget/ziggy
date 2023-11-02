const Foo = struct {
    buf: [32]u8,

    pub fn setTitle(self: *Foo, slice: [:0]const u8) void {
        const len = @min(self.buf.len - 1, slice.len);
        @memcpy(self.buf[0..len], slice[0..]);
        self.buf[len] = 0;
    }

    pub fn bufEmpty(self: *Foo) bool {
        return self.buf[0] == 0;
    }
};

test "setTitle" {
    const expect = @import("std").testing.expect;

    var foo = Foo{ .buf = undefined };

    try expect(foo.bufEmpty());
    foo.setTitle("Hello World");
    try expect(!foo.bufEmpty());
}
