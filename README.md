# Arithmetic & Boolean TAC Generator

A simple compiler front-end built using **Flex and Yacc (Bison)** that generates Three-Address Code (TAC) for arithmetic and Boolean expressions.

## Features

- Arithmetic expressions: `+`, `-`, `*`, `/`
- Relational operators: `<`, `>`, `<=`, `>=`
- Equality operators: `==`, `!=`
- Logical operators: `&&`, `||`, `!`
- Operator precedence and associativity
- Temporary variable and label generation

## Requirements

- GCC
- GNU Make
- Flex
- Yacc / Bison

## Build

```bash
# Release build
make build/parser

# Debug build (AddressSanitizer)
make build/debug
```

## Run

```bash
./build/parser
```

Or:

```bash
./build/debug
```

## Example

Input:

```c
x = (a + b) > c && !(d == e);
```

Output:

```text
x = (a + b) > c && !(d == e);
1: t1 = a + b
2: if t1 > c goto 5
3: t2 = 0
4: goto 6
5: t2 = 1
6: if d == e goto 9
7: t3 = 0
8: goto 10
9: t3 = 1
10: t4 =  ! t3
11: t5 = t2 && t4
12: x = t5
```

The compiler generates Three-Address Code representing the expression.

## Clean

```bash
make clean
```

## License

MIT
