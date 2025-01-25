package callback

// Void is a type that represents the absence of a value.
Void :: distinct rawptr
// EMPTY is a value that represents the absence of a value.
EMPTY : Void = nil


Callback :: struct($T, $P, $R: typeid) {
    callback: proc(T, P) -> R,
    state: T,
    free: proc(T),
}

// Creates a callback that does not require cleanup.
make_without_cleanup :: proc(
    state: $T,
    callback: proc(T, $P) -> $R,
) -> Callback(T, P, R) {
    return {
        callback = callback,
        state = state,
        free = nil,
    }
}

// Creates a callback that requires cleanup.
make_with_cleanup :: proc(
    state: $T,
    callback: proc(T, $P) -> $R,
    free: proc(T),
) -> Callback(T, P, R) {
    return {
        callback = callback,
        state = state,
        free = free,
    }
}

// Creates a callback that may require cleanup.
make :: proc { make_without_cleanup, make_with_cleanup }

// Executes a callback and returns its result.
exec_with_param :: proc(c: Callback($T, $P, $R), param: P) -> R {
    return c.callback(c.state, param)
}

// Executes a callback and returns its result. The callback must not take any parameters.
exec_no_param :: proc(c: Callback($T, Void, $R)) -> R {
    return c.callback(c.state, EMPTY)
}

exec :: proc { exec_no_param, exec_with_param }

// Frees resources associated with a callback.
free :: proc(c: Callback($T, $P, $R)) {
    if c.free != nil {
        c.free(c.state)
    }
}