const std = @import("std");
const expect = std.testing.expect;
const eql = std.testing.eql;

fn foo(alpha: u32, b: u8) void {
    _ = b;
    _ = alpha;
}

pub fn main() !void {
    std.debug.print("Hello World! Here are the args: {s} {d}\n", .{ "arg1", 2 });

    const p = Person.init(15, "lol");
    printName(p);

    const lol = 8;
    foo(23, lol);
}

/// A Person
const Person = struct {
    age: u8,
    name: []const u8,

    pub fn init(age: u8, name: []const u8) Person {
        return Person{
            .age = age,
            .name = name,
        };
    }

    fn getName(self: *Person) ?[]const u8 {
        if (self.age == 35) {
            return self.name;
        }
        return null;
    }
};

fn printName(foobar: *Person) void {
    std.debug.print("foobar name={s}\n", .{foobar.name});
}

test "this is another test" {
    // this is a comment
    var p = Person.init(35, "Thorsten");
    try expect(p.age == 35);
}

test "slicing and iterating" {
    std.debug.print("\n", .{});

    var p = Person{ .age = 18, .name = "foobar" };
    _ = p;

    var people = [_]Person{
        Person.init(33, "Thorsten"),
        Person.init(40, "Anne"),
    };

    for (&people, 0..) |*person, index| {
        std.debug.print("person. name={s}, age={d}\n", .{ person.name, person.age });

        person.age = @intCast(index);
    }

    const Horse = struct {
        breed: ?[]const u8,
    };

    var horses = [_]Horse{
        .{ .breed = "Jack Russell" },
        Horse{ .breed = "Pony" },
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    for (horses, 0..) |horse, index| {
        std.debug.print("horse {d}. breed={?s}\n", .{ index, horse.breed });

        const coolBreed = breed: {
            if (horse.breed) |breed| {
                const string = try std.fmt.allocPrint(allocator, "cool-{s}", .{breed});
                // defer allocator.free(string);
                break :breed string;
            }
            break :breed "not-cool";
        };

        std.debug.print("cool breed: {s}\n", .{coolBreed});
    }
}

test "string building" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const string = try std.fmt.allocPrint(allocator, "{d} + {d} = {s}", .{ 9, 10, "cool" });
    defer allocator.free(string);
}
