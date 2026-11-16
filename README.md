# Luau lexer prototype

This is the first step toward a source-to-source Luau obfuscator: an x64 NASM
program that reads a source file and prints token offsets, kinds, and text.
Whitespace and comments are skipped. It does not transform or execute code.

## Build and run

Requires NASM and GCC on Windows:

```powershell
.\build.ps1
.\build\luau-lexer.exe .\tests\sample.luau
.\tests\run.ps1
```

The initial lexer handles ASCII whitespace, ASCII and UTF-8-byte identifiers,
the listed Luau keywords and operators, decimal and hexadecimal numbers,
single- and double-quoted short strings, line comments, and long-bracket block
comments such as `--[[...]]` and `--[=[...]=]`. Backtick interpolated strings
and malformed numeric literals are not yet supported. Those cases should be
added before using this as an input to transformations.
