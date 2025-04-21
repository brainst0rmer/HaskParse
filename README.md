
# Language Compiler

This repository contains the BNFC grammar, generated front‑end, and an interpreter/CLI for a custom programming language.

## Overview

A complete toolchain has been built using:

- **BNFC** to generate a lexer, parser, and abstract syntax tree in Haskell  
- **Haskell** (`StateT`‑based interpreter) to execute programs  
- A **CLI** driver to parse and run `.mylang` source files  

## Project Structure

```
/
├── mylang.cf            # BNFC grammar definition
├── Makefile             # automates bnfc, build, clean
├── Interpreter.hs       # custom interpreter implementation
├── Mylang/              # BNFC‐generated Haskell modules
│   ├── Abs.hs     # AST data types
│   ├── Lex.hs     # lexer (Alex) 
│   ├── Par.hs     # parser (Happy)
│   ├── Print.hs   # pretty‐printer
│   ├── Skel.hs    # skeleton for tree visitors
│   └── Test.hs    # CLI driver (Main module)
└── testcases/
    └── # sample programs
```

## Prerequisites

- **GHC** (The Glasgow Haskell Compiler)  
- **Alex** & **Happy** (installed via `cabal install alex happy`)  
- **BNFC** (v2.9+), available at http://bnfc.digitalgrammars.com/  

## Build & Install

1. **Generate parser + Makefile**  
   ```bash
   bnfc -d -m mylang.cf
   ```
2. **Compile everything**  
   ```bash
   make
   ```
3. **Build the standalone CLI**  
   ```bash
   ghc -iMylang -o mylang \
     Mylang/Test.hs Interpreter.hs Mylang/*.hs
   ```

A `clean` target in `Makefile` removes generated `.hi`/`.o` files and the `mylang` binary.

## Examples

```mylang
program Demo
begin
  read(x);
  if x then write(x * 2) else write(0);
end
```

## Testing

- **Unit tests** under `testcases/` can be run by:
  ```bash
  for f in testcases/*.mylang; do
    ./Mylang/Test "$f"
  done
  ```
- Exit code `0` indicates success; non‑zero signals parse or runtime error.
