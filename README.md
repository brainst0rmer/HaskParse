# Language Compiler

This repository contains the BNFC grammar and generated parser for a custom programming language.

## Grammar Specification

### Lexical Units

- **Identifiers**  
  A letter followed by letters or digits (e.g., `myVar1`).  
- **Integers**  
  One or more digits (e.g., `42`).  
- **Strings**  
  Double‑quoted (`"..."`), with escapes: `\"`, `\\`, `\n`, `\t`, `\r`, `\f`.  
- **Comments**  
  Start with `!` and run to end of line.

### Reserved Words

These cannot be used as identifiers:
```
program, if, then, else, while, do, read, write, begin, end, array
```

### Operators & Delimiters

All appear inline in the grammar:

- **Arithmetic:** `+`, `-`, `*`, `/`  
- **Assignment:** `=`  
- **Grouping:** `(`, `)`  
- **Statement end:** `;`  
- **List sep:** `,`  
- **Blocks:** `begin`, `end`

### Production Rules Summary

```bnf
Program             ::= "program" Id CompoundStatement

Variable            ::= Id
AssignOp            ::= "="

Type                ::= StandardType
                     | "array" "[" MyInteger "]"

StandardType        ::= "integer"

Statement           ::= Variable AssignOp Expression
                     | ProcedureStatement
                     | CompoundStatement
                     | "if" Expression "then" Statement "else" Statement
                     | "if" Expression "then" Statement
                     | "while" Expression "do" Statement
                     | ReadStatement
                     | WriteStatement

Expression          ::= Expression "+" Term
                     | Expression "-" Term
                     | Term

Term                ::= Term "*" Factor
                     | Term "/" Factor
                     | Factor

Factor              ::= MyInteger
                     | Variable
                     | "(" Expression ")"

ProcedureStatement  ::= Id "(" ")"
                     | Id "(" ExpressionList ")"

ExpressionList      ::= Expression
                     | Expression "," ExpressionList

CompoundStatement   ::= "begin" StatementList "end"

StatementList       ::= Statement
                     | Statement ";" StatementList

ReadStatement       ::= "read" "(" Variable ")"

WriteStatement      ::= "write" "(" Expression ")"
```