;=============================================================================|
;  _______ _________          _______  _______                                |
;  (  ____ \\__   __/|\     /|(  ____ \(  ____ )                              |
;  | (    \/   ) (   | )   ( || (    \/| (    )|                              |
;  | (__       | |   | (___) || (__    | (____)|    By Hákon Hjaltalín.       |
;  |  __)      | |   |  ___  ||  __)   |     __)    Licensed under MIT.       |
;  | (         | |   | (   ) || (      | (\ (                                 |
;  | (____/\   | |   | )   ( || (____/\| ) \ \__                              |
;  (_______/   )_(   |/     \|(_______/|/   \__/                              |
;=============================================================================|

bits 64

console_mode_number     dd 0    ; Console mode number
console_columns         dq 0    ; Number of columns
console_rows            dq 0    ; Number of rows
console_attribute       dq EFI_WHITE | EFI_BACKGROUND_BLACK

console_x               dq 0    ; X position
console_y               dq 0    ; Y position

;=============================================================================;
; console_init                                                                ;
;    - Initialize console                                                     ;
;=============================================================================;
console_init:
    mov rdx, [console_mode]
    mov dword eax, [rdx+4]
    mov dword [console_mode_number], eax

    mov qword rcx, [console_out]
    xor rdx, rdx
    mov dword edx, [console_mode_number]
    lea qword r8, [console_columns]
    lea qword r9, [console_rows]
    call [console_out_query_mode]

    mov qword rcx, [console_out]
    call [console_out_clear_screen]

    mov qword rcx, [console_out]
    mov rdx, 1
    call [console_out_enable_cursor]

    ret

;=============================================================================;
; console_set_attribute                                                       ;
;    - Update console attribute                                               ;
;=============================================================================;
console_set_attribute:
    mov qword rcx, [console_out]
    mov qword rdx, [console_attribute]
    call [console_out_set_attribute]
    ret

;=============================================================================;
; console_move_cursor                                                         ;
;    - Update console cursor                                                  ;
;=============================================================================;
console_move_cursor:
    mov qword rcx, [console_out]
    mov qword rdx, [console_x]
    mov qword r8, [console_y]
    call [console_out_set_cursor_position]
    ret

;=============================================================================;
; console_print_string                                                        ;
;    - Print a string to the console                                          ;
;    @param RDX = Location of string                                          ;
;=============================================================================;
console_print_string:
    mov qword rcx, [console_out]
    call [console_out_output_string]
    ret
