default rel

global main
extern fopen
extern fseek
extern ftell
extern malloc
extern fread
extern fclose
extern printf
extern free

section .rdata
mode_read       db "rb", 0
usage_text      db "Usage: luau-lexer <file.luau>", 10, 0
open_error      db "Could not open input file.", 10, 0
read_error      db "Could not read input file.", 10, 0
size_error      db "Input file is too large.", 10, 0
memory_error    db "Could not allocate input buffer.", 10, 0
string_error    db "Unterminated or multiline short string at byte %llu.", 10, 0
comment_error   db "Unterminated block comment at byte %llu.", 10, 0
token_error     db "Unexpected character at byte %llu.", 10, 0
token_format    db "%llu  %-10s %.*s", 10, 0

kw_and          db "and"
kw_break        db "break"
kw_continue     db "continue"
kw_do           db "do"
kw_else         db "else"
kw_elseif       db "elseif"
kw_end          db "end"
kw_false        db "false"
kw_for          db "for"
kw_function     db "function"
kw_if           db "if"
kw_in           db "in"
kw_local        db "local"
kw_nil          db "nil"
kw_not          db "not"
kw_or           db "or"
kw_repeat       db "repeat"
kw_return       db "return"
kw_then         db "then"
kw_true         db "true"
kw_until        db "until"
kw_while        db "while"
kw_type         db "type"
kw_export       db "export"

kw_ptrs         dq kw_and, kw_break, kw_continue, kw_do, kw_else, kw_elseif
                dq kw_end, kw_false, kw_for, kw_function, kw_if, kw_in
                dq kw_local, kw_nil, kw_not, kw_or, kw_repeat, kw_return
                dq kw_then, kw_true, kw_until, kw_while, kw_type, kw_export
kw_lens         dd 3, 5, 8, 2, 4, 6, 3, 5, 3, 8, 2, 2
                dd 5, 3, 3, 2, 6, 6, 4, 4, 5, 5, 4, 6
kw_count        equ 24

op_ellipsis     db "..."
op_concat_eq    db "..="
op_idiv_eq      db "//="
op_eq           db "=="
op_ne           db "~="
op_le           db "<="
op_ge           db ">="
op_add_eq       db "+="
op_sub_eq       db "-="
op_mul_eq       db "*="
op_div_eq       db "/="
op_mod_eq       db "%="
op_pow_eq       db "^="
op_concat       db ".."
op_idiv         db "//"
op_arrow        db "->"
op_type_assert  db "::"
op_shl          db "<<"
op_shr          db ">>"
op_amp_eq       db "&="
op_pipe_eq      db "|="
op_single_plus  db "+"
op_single_minus db "-"
op_single_star  db "*"
op_single_slash db "/"
op_single_mod   db "%"
op_single_pow   db "^"
op_single_hash  db "#"
op_single_eq    db "="
op_single_lt    db "<"
op_single_gt    db ">"
op_single_lparen db "("
op_single_rparen db ")"
op_single_lbrace db "{"
op_single_rbrace db "}"
op_single_lbracket db "["
op_single_rbracket db "]"
op_single_semi  db ";"
op_single_colon db ":"
op_single_comma db ","
op_single_dot   db "."
op_single_qmark db "?"
op_single_amp   db "&"
op_single_pipe  db "|"
op_single_tilde db "~"

op_ptrs         dq op_ellipsis, op_concat_eq, op_idiv_eq
                dq op_eq, op_ne, op_le, op_ge, op_add_eq, op_sub_eq
                dq op_mul_eq, op_div_eq, op_mod_eq, op_pow_eq, op_concat
                dq op_idiv, op_arrow, op_type_assert, op_shl, op_shr
                dq op_amp_eq, op_pipe_eq
                dq op_single_plus, op_single_minus, op_single_star
                dq op_single_slash, op_single_mod, op_single_pow
                dq op_single_hash, op_single_eq, op_single_lt, op_single_gt
                dq op_single_lparen, op_single_rparen, op_single_lbrace
                dq op_single_rbrace, op_single_lbracket, op_single_rbracket
                dq op_single_semi, op_single_colon, op_single_comma
                dq op_single_dot, op_single_qmark, op_single_amp
                dq op_single_pipe, op_single_tilde
op_lens         dd 3, 3, 3
                dd 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
                dd 2, 2
                dd 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                dd 1, 1, 1, 1, 1, 1, 1, 1
op_count        equ 45

token_identifier db "identifier", 0
token_keyword   db "keyword", 0
token_number    db "number", 0
token_string    db "string", 0
token_symbol    db "symbol", 0

section .text

main:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    sub rsp, 104
    mov qword [rbp - 40], 0
    mov qword [rbp - 48], 0

    cmp ecx, 2
    jae .have_argument
    lea rcx, [usage_text]
    xor eax, eax
    call printf
    mov eax, 2
    jmp .return

.have_argument:
    mov [rbp - 32], rdx
    mov rax, [rdx + 8]
    mov rcx, rax
    lea rdx, [mode_read]
    call fopen
    test rax, rax
    jz .open_failed
    mov [rbp - 40], rax

    mov rcx, rax
    xor edx, edx
    mov r8d, 2
    call fseek
    test eax, eax
    jnz .read_failed

    mov rcx, [rbp - 40]
    call ftell
    test eax, eax
    js .read_failed
    cmp rax, 0x7fffffff
    ja .size_failed
    mov [rbp - 56], rax

    mov rcx, [rbp - 40]
    xor edx, edx
    xor r8d, r8d

    call fseek
    test eax, eax
    jnz .read_failed

    mov rcx, [rbp - 56]
    inc rcx
    call malloc
    test rax, rax
    jz .memory_failed
    mov [rbp - 48], rax

    mov rcx, [rbp - 48]
    mov edx, 1
    mov r8, [rbp - 56]
    mov r9, [rbp - 40]
    call fread
    cmp rax, [rbp - 56]
    jne .read_failed

    mov rax, [rbp - 48]
    add rax, [rbp - 56]
    mov byte [rax], 0
    mov rcx, [rbp - 40]
    call fclose
    mov qword [rbp - 40], 0

    mov rsi, [rbp - 48]
    mov rdi, [rbp - 56]
    xor ebx, ebx

.scan:
    cmp rbx, rdi
    jae .scan_done
    mov al, [rsi + rbx]

    cmp al, 32
    je .skip_space
    cmp al, 9
    jb .not_horizontal_space
    cmp al, 13
    jbe .skip_space
.not_horizontal_space:
    cmp al, '-'
    jne .check_identifier
    lea r10, [rbx + 1]
    cmp r10, rdi
    jae .check_identifier
    cmp byte [rsi + r10], '-'
    jne .check_identifier
    add rbx, 2
    cmp rbx, rdi
    jae .line_comment
    cmp byte [rsi + rbx], '['
    jne .line_comment
    mov qword [rbp - 96], 0
    inc rbx
.block_comment_open_equals:
    cmp rbx, rdi
    jae .line_comment
    cmp byte [rsi + rbx], '='
    jne .block_comment_open_end
    inc qword [rbp - 96]
    inc rbx
    jmp .block_comment_open_equals
.block_comment_open_end:
    cmp byte [rsi + rbx], '['
    jne .line_comment
    inc rbx
.block_comment_loop:
    cmp rbx, rdi
    jae .unterminated_comment
    cmp byte [rsi + rbx], ']'
    jne .block_comment_advance
    lea r10, [rbx + 1]
    mov r11, [rbp - 96]
.block_comment_close_equals:
    test r11, r11
    jz .block_comment_close_end
    cmp r10, rdi
    jae .block_comment_advance
    cmp byte [rsi + r10], '='
    jne .block_comment_advance
    inc r10
    dec r11
    jmp .block_comment_close_equals
.block_comment_close_end:
    cmp r10, rdi
    jae .block_comment_advance
    cmp byte [rsi + r10], ']'
    jne .block_comment_advance
    inc r10
    mov rbx, r10
    jmp .scan
.block_comment_advance:
    inc rbx
    jmp .block_comment_loop

.line_comment:
    cmp rbx, rdi
    jae .scan
    cmp byte [rsi + rbx], 10
    je .scan
    inc rbx
    jmp .line_comment

.skip_space:
    inc rbx
    jmp .scan

.check_identifier:
    cmp al, 'A'
    jb .identifier_lower
    cmp al, 'Z'
    jbe .identifier_start
.identifier_lower:
    cmp al, 'a'
    jb .identifier_underscore
    cmp al, 'z'
    jbe .identifier_start
.identifier_underscore:
    cmp al, '_'
    je .identifier_start
    cmp al, 128
    jae .identifier_start
    jmp .check_string

.identifier_start:
    mov [rbp - 72], rbx
    inc rbx
.identifier_loop:
    cmp rbx, rdi
    jae .identifier_done
    mov al, [rsi + rbx]
    cmp al, 'A'
    jb .identifier_loop_lower
    cmp al, 'Z'
    jbe .identifier_advance
.identifier_loop_lower:
    cmp al, 'a'
    jb .identifier_loop_digit
    cmp al, 'z'
    jbe .identifier_advance
.identifier_loop_digit:
    cmp al, '0'
    jb .identifier_loop_underscore
    cmp al, '9'
    jbe .identifier_advance
.identifier_loop_underscore:
    cmp al, '_'
    je .identifier_advance
    cmp al, 128
    jb .identifier_done
.identifier_advance:
    inc rbx
    jmp .identifier_loop
.identifier_done:
    mov rax, rbx
    sub rax, [rbp - 72]
    mov [rbp - 80], rax
    mov rcx, rsi
    add rcx, [rbp - 72]
    mov edx, eax
    call is_keyword
    test eax, eax
    jz .identifier_kind
    lea rax, [token_keyword]
    jmp .set_identifier_kind
.identifier_kind:
    lea rax, [token_identifier]
.set_identifier_kind:
    mov [rbp - 88], rax
    jmp .emit_token

.check_string:
    cmp al, '"'
    je .string_start
    cmp al, "'"
    je .string_start
    jmp .check_number

.string_start:
    mov [rbp - 72], rbx
    mov dl, al
    inc rbx
.string_loop:
    cmp rbx, rdi
    jae .unterminated_string
    mov al, [rsi + rbx]
    cmp al, 10
    je .unterminated_string
    cmp al, 13
    je .unterminated_string
    cmp al, '\'
    jne .string_check_end
    add rbx, 2
    jmp .string_loop
.string_check_end:
    cmp al, dl
    je .string_end
    inc rbx
    jmp .string_loop
.string_end:
    inc rbx
    mov rax, rbx
    sub rax, [rbp - 72]
    mov [rbp - 80], rax
    lea rax, [token_string]
    mov [rbp - 88], rax
    jmp .emit_token

.check_number:
    cmp al, '.'
    jne .number_maybe_digit
    lea r10, [rbx + 1]
    cmp r10, rdi
    jae .check_operator
    mov dl, [rsi + r10]
    cmp dl, '0'
    jb .check_operator
    cmp dl, '9'
    ja .check_operator
    jmp .number_leading_dot
.number_maybe_digit:
    cmp al, '0'
    jb .check_operator
    cmp al, '9'
    ja .check_operator

.number_start:
    mov [rbp - 72], rbx
    cmp byte [rsi + rbx], '0'
    jne .decimal_digits
    lea r10, [rbx + 1]
    cmp r10, rdi
    jae .decimal_digits
    mov al, [rsi + r10]
    cmp al, 'x'
    je .hex_start
    cmp al, 'X'
    je .hex_start
    jmp .decimal_digits

.number_leading_dot:
    mov [rbp - 72], rbx
    inc rbx
.leading_fraction_digits:
    cmp rbx, rdi
    jae .decimal_exponent
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .decimal_exponent
    cmp al, '9'
    ja .decimal_exponent
    inc rbx
    jmp .leading_fraction_digits

.decimal_digits:
    cmp rbx, rdi
    jae .decimal_exponent
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .decimal_fraction
    cmp al, '9'
    ja .decimal_fraction
    inc rbx
    jmp .decimal_digits
.decimal_fraction:
    cmp byte [rsi + rbx], '.'
    jne .decimal_exponent
    lea r10, [rbx + 1]
    cmp r10, rdi
    jae .decimal_take_dot
    cmp byte [rsi + r10], '.'
    je .decimal_exponent
.decimal_take_dot:
    inc rbx
.decimal_fraction_digits:
    cmp rbx, rdi
    jae .decimal_exponent
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .decimal_exponent
    cmp al, '9'
    ja .decimal_exponent
    inc rbx
    jmp .decimal_fraction_digits
.decimal_exponent:
    cmp rbx, rdi
    jae .number_done
    mov al, [rsi + rbx]
    cmp al, 'e'
    je .decimal_take_exponent
    cmp al, 'E'
    jne .number_done
.decimal_take_exponent:
    inc rbx
    cmp rbx, rdi
    jae .number_done
    mov al, [rsi + rbx]
    cmp al, '+'
    je .decimal_exponent_sign
    cmp al, '-'
    jne .decimal_exponent_digits
.decimal_exponent_sign:
    inc rbx
.decimal_exponent_digits:
    cmp rbx, rdi
    jae .number_done
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .number_done
    cmp al, '9'
    ja .number_done
    inc rbx
    jmp .decimal_exponent_digits

.hex_start:
    add rbx, 2
.hex_digits:
    cmp rbx, rdi
    jae .hex_fraction
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .hex_letter_low
    cmp al, '9'
    jbe .hex_advance
.hex_letter_low:
    cmp al, 'a'
    jb .hex_letter_high
    cmp al, 'f'
    jbe .hex_advance
.hex_letter_high:
    cmp al, 'A'
    jb .hex_fraction
    cmp al, 'F'
    ja .hex_fraction
.hex_advance:
    inc rbx
    jmp .hex_digits
.hex_fraction:
    cmp rbx, rdi
    jae .hex_exponent
    cmp byte [rsi + rbx], '.'
    jne .hex_exponent
    lea r10, [rbx + 1]
    cmp r10, rdi
    jae .hex_take_dot
    cmp byte [rsi + r10], '.'
    je .hex_exponent
.hex_take_dot:
    inc rbx
.hex_fraction_digits:
    cmp rbx, rdi
    jae .hex_exponent
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .hex_fraction_low
    cmp al, '9'
    jbe .hex_fraction_advance
.hex_fraction_low:
    cmp al, 'a'
    jb .hex_fraction_high
    cmp al, 'f'
    jbe .hex_fraction_advance
.hex_fraction_high:
    cmp al, 'A'
    jb .hex_exponent
    cmp al, 'F'
    ja .hex_exponent
.hex_fraction_advance:
    inc rbx
    jmp .hex_fraction_digits
.hex_exponent:
    cmp rbx, rdi
    jae .number_done
    mov al, [rsi + rbx]
    cmp al, 'p'
    je .hex_take_exponent
    cmp al, 'P'
    jne .number_done
.hex_take_exponent:
    inc rbx
    cmp rbx, rdi
    jae .number_done
    mov al, [rsi + rbx]
    cmp al, '+'
    je .hex_exponent_sign
    cmp al, '-'
    jne .hex_exponent_digits
.hex_exponent_sign:
    inc rbx
.hex_exponent_digits:
    cmp rbx, rdi
    jae .number_done
    mov al, [rsi + rbx]
    cmp al, '0'
    jb .number_done
    cmp al, '9'
    ja .number_done
    inc rbx
    jmp .hex_exponent_digits

.number_done:
    mov rax, rbx
    sub rax, [rbp - 72]
    mov [rbp - 80], rax
    lea rax, [token_number]
    mov [rbp - 88], rax
    jmp .emit_token

.check_operator:
    mov rcx, rsi
    add rcx, rbx
    mov rdx, rdi
    sub rdx, rbx
    call match_operator
    test eax, eax
    jz .unexpected_character
    mov [rbp - 72], rbx
    mov [rbp - 80], rax
    add rbx, rax
    lea rax, [token_symbol]
    mov [rbp - 88], rax

.emit_token:
    mov rcx, token_format
    mov rdx, [rbp - 72]
    mov r8, [rbp - 88]
    mov r9d, [rbp - 80]
    lea rax, [rsi + rdx]
    mov [rsp + 32], rax
    mov rdx, [rbp - 72]
    xor eax, eax
    call printf
    jmp .scan

.scan_done:
    mov rcx, [rbp - 48]
    call free
    xor eax, eax
    jmp .return

.unterminated_string:
    mov rcx, string_error
    mov rdx, [rbp - 72]
    xor eax, eax
    call printf
    mov eax, 1
    jmp .cleanup

.unterminated_comment:
    mov rcx, comment_error
    mov rdx, rbx
    xor eax, eax
    call printf
    mov eax, 1
    jmp .cleanup

.unexpected_character:
    mov rcx, token_error
    mov rdx, rbx
    xor eax, eax
    call printf
    mov eax, 1
    jmp .cleanup

.open_failed:
    lea rcx, [open_error]
    xor eax, eax
    call printf
    mov eax, 1
    jmp .return

.read_failed:
    lea rcx, [read_error]
    xor eax, eax
    call printf
    mov eax, 1
    jmp .cleanup

.size_failed:
    lea rcx, [size_error]
    xor eax, eax
    call printf
    mov eax, 1
    jmp .cleanup

.memory_failed:
    lea rcx, [memory_error]
    xor eax, eax
    call printf
    mov eax, 1
    jmp .cleanup

.cleanup:
    mov rcx, [rbp - 40]
    test rcx, rcx
    jz .cleanup_buffer
    call fclose
.cleanup_buffer:
    mov rcx, [rbp - 48]
    test rcx, rcx
    jz .return
    call free
.return:
    add rsp, 104
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

is_keyword:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 16], rdx
    xor r11d, r11d
.keyword_loop:
    cmp r11d, kw_count
    jae .keyword_no
    lea rax, [kw_lens]
    mov eax, [rax + r11 * 4]
    cmp eax, [rbp - 16]
    jne .keyword_next
    mov [rbp - 32], rax
    lea rax, [kw_ptrs]
    mov r10, [rax + r11 * 8]
    xor r9d, r9d
.keyword_compare:
    mov r8, [rbp - 8]
    mov al, [r8 + r9]
    cmp al, [r10 + r9]
    jne .keyword_next
    inc r9
    cmp r9, [rbp - 32]
    jb .keyword_compare
    mov eax, 1
    jmp .keyword_return
.keyword_next:
    inc r11d
    jmp .keyword_loop
.keyword_no:
    xor eax, eax
.keyword_return:
    add rsp, 48
    pop rbp
    ret

match_operator:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    mov [rbp - 8], rcx
    mov [rbp - 16], rdx
    xor r11d, r11d
.operator_loop:
    cmp r11d, op_count
    jae .operator_no
    lea rax, [op_lens]
    mov eax, [rax + r11 * 4]
    cmp rax, [rbp - 16]
    ja .operator_next
    mov [rbp - 32], rax
    lea rax, [op_ptrs]
    mov r10, [rax + r11 * 8]
    xor r9d, r9d
.operator_compare:
    mov r8, [rbp - 8]
    mov al, [r8 + r9]
    cmp al, [r10 + r9]
    jne .operator_next
    inc r9
    cmp r9, [rbp - 32]
    jb .operator_compare
    mov eax, [rbp - 32]
    jmp .operator_return
.operator_next:
    inc r11d
    jmp .operator_loop
.operator_no:
    xor eax, eax
.operator_return:
    add rsp, 48
    pop rbp
    ret
