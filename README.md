# Callback Library

**A lightweight Odin library for creating stateful callbacks.**  
This library avoids heap allocations by default, relying solely on stack memory. It also supports optional cleanup functions for managing resources. Licensed under the MIT License.

---

## Features

- **Stateful callbacks**: Pair state with a callback function.
- **Memory-efficient**: No heap allocations.
- **Optional cleanup**: Support for resource cleanup when needed.

---

## Installation

Copy the `callback` package into your Odin project. Import it with:

```odin
import "path/to/callback"
```

---

## API Overview

### Types

- **`Callback(TParam, TReturn)`**: A structure that holds a callback, its state, and an optional cleanup function.

---

### Functions

- **`make_without_cleanup(capture: rawptr, callback: proc(rawptr, P) -> R)`**  
  Creates a callback without a cleanup function.

- **`make_with_cleanup(capture: rawptr, callback: proc(rawptr, P) -> R, free: proc(rawptr))`**  
  Creates a callback with a cleanup function for resource management.

- **`make`**  
  Procedure union for creating a callback with or without cleanup.

- **`exec(c: Callback(P, R), param: P) -> R`**  
  Executes the callback and returns the result.

- **`free(c: Callback(P, R))`**  
  Invokes the cleanup function if it is set.

---

## Usage Example

```odin
package main

import "callback"

make_adder :: proc(base: int) -> cb.Callback(int, int) {
    return cb.make(
        capture = new_clone(base),
        callback = proc(capture: ^int, param: int) -> int {
            capture^ += param
            return capture^
        },
        free = proc(capture: rawptr) {
            free(cast(^int)capture)
        },
    )
}

main :: proc() {
    adder := make_adder(10)
    defer cb.free(adder) // Cleanup

    cb.exec(adder, 5) // 15
    cb.exec(adder, 6) // 21
    cb.exec(adder, 7) // 28
}
```

---

## License

This library is licensed under the [MIT License](LICENSE).