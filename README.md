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

- **`Callback(T, R)`**: A structure that holds a callback, its state, and an optional cleanup function.

---

### Functions

- **`make_without_cleanup(state: T, callback: proc(T) -> R)`**  
  Creates a callback without a cleanup function.

- **`make_with_cleanup(state: T, callback: proc(T) -> R, free: proc(T))`**  
  Creates a callback with a cleanup function for resource management.

- **`make`**  
  Procedure union for creating a callback with or without cleanup.

- **`exec(c: Callback(T, R)) -> R`**  
  Executes the callback and returns the result.

- **`free(c: Callback(T, R))`**  
  Invokes the cleanup function if it is set.

---

## Usage Example

```odin
package main

import "callback"

main :: proc() {
    // Create a callback without cleanup
    cb_no_cleanup := callback.make(42, proc(state: int) -> int {
        return state * 2;
    });
    result := callback.exec(cb_no_cleanup); 
    // result == 84

    // Create a callback with cleanup
    state := new(int)
    state^ = 2;
    cb_with_cleanup := callback.make(state, proc(state: ^int) -> int {
        return state^ + 10;
    }, proc(state: ^int) {
        // Free resources if necessary
        free(state);
    });

    result := callback.exec(cb_with_cleanup);
    // result == 12

    callback.free(cb_with_cleanup); // `state` is freed
}
```

---

## License

This library is licensed under the [MIT License](LICENSE).