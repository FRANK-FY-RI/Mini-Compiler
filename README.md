# Arithmetic & Boolean TAC Generator

A compiler front-end built using **Flex and Yacc (Bison)** that generates Three-Address Code (TAC) for arithmetic and Boolean expressions using single-pass **backpatching** and **short-circuit evaluation**.

## Features

- **Arithmetic expressions:** `+`, `-`, `*`, `/`
- **Relational operators:** `<`, `>`, `<=`, `>=`
- **Equality operators:** `==`, `!=`
- **Short-circuit Boolean evaluation:** `&&`, `||`, `!` using backpatching (`truelist`, `falselist`, and marker non-terminals)
- **Automatic Boolean materialization:** Converts jump-based control flow into numeric `0`/`1` values upon assignment to variables
- **Strict Operator Precedence & Associativity:** Standard C-like parsing rules
- **AddressSanitizer clean:** Leak-free memory management for dynamic expression attributes and jump lists

## Requirements

- GCC / Clang
- GNU Make
- Flex
- Yacc / Bison

## Build

```bash
# Release build
make build/parser

# Debug build (AddressSanitizer + LeakSanitizer enabled)
make build/debug
```

## Run

```bash
./build/parser
```

Or run the debug executable:

```bash
./build/debug
```

## Example

### Input

```c
x = (a + b) > c && !(d == e);
```

### Generated TAC

```text
1: t1 = a + b
2: if t1 > c goto 4
3: goto 7
4: if d == e goto 7
5: goto 6
6: goto 9
7: t2 = 0
8: goto 10
9: t2 = 1
10: x = t2
```

### How It Works

1. **Short-Circuit Evaluation:** Relational expressions emit conditional and unconditional jumps with unresolved target labels (e.g., `if ... goto ?`, `goto ?`).
2. **Backpatching:** As higher-level Boolean operators (`&&`, `||`, `!`) are reduced, marker non-terminals capture the target instruction addresses, merging and resolving pending jump lists (`truelist` and `falselist`) without requiring an AST traversal.
3. **Value Materialization:** When a Boolean control-flow expression is assigned to an identifier, target jump labels are backpatched to blocks that assign `1` (true) or `0` (false) to a temporary variable before binding it to the destination variable.

## Clean

```bash
make clean
```

## License

MIT