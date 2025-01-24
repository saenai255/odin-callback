package callback

// Void is a type that represents the absence of a value.
Void :: distinct rawptr
// EMPTY is a value that represents the absence of a value.
EMPTY : Void = nil


Callback :: struct($T, $R: typeid) {
    callback: proc(T) -> R,
    state: T,
    free: proc(T),
}

// Creates a callback that does not require cleanup.
make_without_cleanup :: proc(
    state: $T,
    callback: proc(T) -> $R,
) -> Callback(T, R) {
    return {
        callback = callback,
        state = state,
        free = nil,
    }
}

// Creates a callback that requires cleanup.
make_with_cleanup :: proc(
    state: $T,
    callback: proc(T) -> $R,
    free: proc(T),
) -> Callback(T, R) {
    return {
        callback = callback,
        state = state,
        free = free,
    }
}

// Creates a callback that may require cleanup.
make :: proc { make_without_cleanup, make_with_cleanup }

// Executes a callback and returns its result.
exec :: proc(c: Callback($T, $R)) -> R {
    return c.callback(c.state)
}

// Frees resources associated with a callback.
free :: proc(c: Callback($T, $R)) {
    if c.free != nil {
        c.free(c.state)
    }
}