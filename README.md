# Language Compiler

This repository contains the BNFC grammar and generated parser for a custom language .

## Grammar Specification

### Lexical Units
- **Identifiers**: A sequence of letters followed by letters or digits (case insensitive, max 32 chars).
- **Numbers**: Only integers are allowed.
- **Strings**: Enclosed in apostrophes (`'`), with escape sequences (`\n`, `\t`, `\'`).
- **Comments**: Start with `!` and continue until the end of the line.

### Reserved Words
The following are reserved keywords and cannot be used as identifiers:
```
and, array, begin, integer, do, else, end, function, if, of, or, not, procedure, program,
read, then, var, while, write
```

### Operators & Delimiters
- **Delimiters**: `() [] ; : . , * - + / < = >`
- **Compound Symbols**: `<>`, `:=`, `<=`, `>=`

### Production Rules
```
Program ::= "program" Id ";"
Type ::= StandardType | "array" "[" Num "]"
StandardType ::= "integer"
Statement ::= Variable AssignOp Expression
            | ProcedureStatement
            | CompoundStatement
            | "if" Expression "then" Statement "else" Statement
            | "if" Expression "then" Statement
            | "while" Expression "do" Statement
            | ReadStatement
            | WriteStatement
Arguments ::= "(" ParameterList ")" | "(" ")"
ReadStatement ::= "read" "(" IdentifierList ")"
WriteStatement ::= "write" "(" OutputList ")"
IdentifierList ::= Variable | Variable "," IdentifierList
OutputList ::= OutputItem | OutputItem "," OutputList
OutputItem ::= StringLit | ExpressionList
Factor ::= Id "[" Expression "]"
```

