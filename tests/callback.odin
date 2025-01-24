package tests

import "core:testing"
import cb ".."

@(test)
callback_gets_called :: proc(t: ^testing.T) {
    state := 42
    fn := cb.make(
        state = &state,
        callback = proc(state: ^int) -> cb.Void {
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
        callback = proc(state: ^int) -> cb.Void {
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
        callback = proc(state: int) -> int {
            return state * 2
        },
    )

    result := cb.exec(fn)
    testing.expect_value(t, result, 84)
}