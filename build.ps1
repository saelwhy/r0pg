$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$output = Join-Path $root 'build'
New-Item -ItemType Directory -Force -Path $output | Out-Null

& nasm -f win64 (Join-Path $root 'lexer.asm') -o (Join-Path $output 'lexer.obj')
if ($LASTEXITCODE -ne 0) {
    throw "NASM failed with exit code $LASTEXITCODE"
}

& gcc (Join-Path $output 'lexer.obj') -o (Join-Path $output 'luau-lexer.exe')
if ($LASTEXITCODE -ne 0) {
    throw "GCC linker failed with exit code $LASTEXITCODE"
}

Write-Output (Join-Path $output 'luau-lexer.exe')
