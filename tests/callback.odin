package tests

import "core:testing"
import cb ".."

@(test)
callback_gets_called :: proc(t: ^testing.T) {
    state := 42
    fn := cb.make(
        state = &state,
        callback = proc(state: ^int, param: cb.Void) -> cb.Void {
            state^ += 1
            return cb.EMPTY
        },
    )

    cb.exec(fn)
    testing.expect_value(t, state, 43)
    cb.exec(fn)
    testing.expect_value(t, state, 44)
}

@(test)
callback_free_gets_called :: proc(t: ^testing.T) {
    state := new(int)
    state^ = 42
    fn := cb.make(
        state = state,
        callback = proc(state: ^int, param: cb.Void) -> cb.Void {
            state^ += 1
            return cb.EMPTY
        },
        free = proc(state: ^int) {
            free(state)
        },
    )

    defer cb.free(fn)
    cb.exec(fn)
    testing.expect_value(t, state^, 43)
    cb.exec(fn)
    testing.expect_value(t, state^, 44)
}

@(test)
callback_computes_value :: proc(t: ^testing.T) {
    state := 42
    fn := cb.make(
        state = state,
        callback = proc(state: int, param: cb.Void) -> int {
            return state * 2
        },
    )

    result := cb.exec(fn)
    testing.expect_value(t, result, 84)
}

make_adder :: proc(base: int) -> cb.Callback(^int, int, int) {
    return cb.make(
        state = new_clone(base),
        callback = proc(state: ^int, param: int) -> int {
            state^ += param
            return state^
        },
        free = proc(state: ^int) {
            free(state)
        },
    )
}

@(test)
callback_with_param :: proc(t: ^testing.T) {
    adder := make_adder(10)
    defer cb.free(adder)

    testing.expect_value(t, cb.exec(adder, 5), 15)
    testing.expect_value(t, cb.exec(adder, 7), 22)
    testing.expect_value(t, cb.exec(adder, 3), 25)
}