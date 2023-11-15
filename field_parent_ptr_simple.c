#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>

enum position {
    LEFT,
    RIGHT
};

struct child {
    const char *name;
    enum position position;
};

struct parent {
    const char *name;
    struct child left;
    struct child right;
};

const char *parentName(const struct child *child) {
    uintptr_t offset = 0;
    switch (child->position) {
        // 1. Turn a `0` into a `struct parent *` pointer
        // 2. Access `->left` or `->right`, take pointer of that.
        // 3. That increased the `0` address to the field address
        // -> our offset
        case LEFT:
            offset = (uintptr_t) &(((struct parent *)0)->left);
            break;
        case RIGHT:
            offset = (uintptr_t) &(((struct parent *)0)->right);
            break;
    }
    // Now we can take that offset and get to the name
    struct parent *parent = (struct parent *)((char *)child - offset);
    return parent->name;
}

int main(void) {
    struct parent parent = {
        .name = "bob",
        .left = { .name = "child1", .position = LEFT },
        .right = { .name = "child2", .position = RIGHT },
    };

    assert(strcmp(parentName(&parent.left), "bob") == 0);
    assert(strcmp(parentName(&parent.right), "bob") == 0);

    printf("And bob's... not your uncle?\n");

    return 0;
}
