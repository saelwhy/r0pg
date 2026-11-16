$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$exe = Join-Path $root 'build\luau-lexer.exe'

& (Join-Path $root 'build.ps1') | Out-Null
$output = & $exe (Join-Path $PSScriptRoot 'sample.luau')
if ($LASTEXITCODE -ne 0) {
    throw "Lexer exited with code $LASTEXITCODE"
}

$joined = $output -join "`n"
foreach ($expected in @(
    'keyword\s+local',
    'keyword\s+function',
    'identifier\s+greet',
    'identifier\s+name',
    'number\s+1\.25e\+2',
    'identifier\s+andrew',
    'number\s+1',
    'symbol\s+\.\.',
    'number\s+0x1\.fp2',
    'identifier\s+after_comments',
    'string\s+"hi, \\"there\\" "',
    'identifier\s+print'
)) {
    if ($joined -notmatch $expected) {
        throw "Expected token pattern not found: $expected"
    }
}

if ($joined -match 'identifier\s+(does|still|close)') {
    throw 'Text inside a long comment was tokenized'
}

$badComment = [IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllText($badComment, '--[=[ comment without a closing marker')
    $errorOutput = & $exe $badComment 2>&1
    if ($LASTEXITCODE -ne 1 -or ($errorOutput -join "`n") -notmatch 'Unterminated block comment') {
        throw 'Unterminated long comment case failed'
    }
}
finally {
    Remove-Item -LiteralPath $badComment -ErrorAction SilentlyContinue
}

Write-Output 'Lexer smoke tests passed.'
