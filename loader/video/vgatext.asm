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

bits 32

%define VGA_TEXT_VIDEO_MEMORY       0xB8000
%define VGA_TEXT_COLS               80
%define VGA_TEXT_LINES              25

vga_text_cursor_x                   db 0
vga_text_cursor_y                   db 0
vga_text_color                      db 0x0F

;=============================================================================;
; vga_text_put_char                                                           ;
;    - Print a single ASCII character                                         ;
;=============================================================================;
vga_text_put_char:
    pusha

    cmp al, 0x08
    jne .cont1

    cmp byte [vga_text_cursor_x], 0
    je .cont1

    dec byte [vga_text_cursor_x]
    jmp .finish

.cont1:
    cmp al, 0x09
    je .tab

    cmp al, 0x0D
    je .cr

    cmp al, 0x0A
    je .nl

    cmp al, 0x20
    jb .finish

    mov bl, al
    xor eax, eax

    mov ecx, VGA_TEXT_COLS * 2
    mov byte al, [vga_text_cursor_y]
    mul ecx
    push eax

    mov byte al, [vga_text_cursor_x]
    mov cl, 2
    mul cl
    pop ecx
    add eax, ecx

    xor ecx, ecx
    mov edi, VGA_TEXT_VIDEO_MEMORY
    add edi, eax

    mov dl, bl
    mov byte dh, [vga_text_color]
    mov word [edi], dx

    inc byte [vga_text_cursor_x]
    jmp .finish

.tab:
    add byte [vga_text_cursor_x], 8
    and byte [vga_text_cursor_x], ~(8-1)
    jmp .finish

.cr:
    mov byte [vga_text_cursor_x], 0
    jmp .finish

.nl:
    mov byte [vga_text_cursor_x], 0
    inc byte [vga_text_cursor_y]

.finish:
    cmp byte [vga_text_cursor_x], 80
    jb .finish2

    mov byte [vga_text_cursor_x], 0
    inc byte [vga_text_cursor_y]

.finish2:
    popa
    call vga_text_move_cursor
    ret

;=============================================================================;
; vga_text_print_string                                                       ;
;    - Print a string                                                         ;
;    @param ESI = Pointer to string                                           ;
;=============================================================================;
vga_text_print_string:
    pusha

.loop:
    lodsb

    test al, al
    jz .done

    call vga_text_put_char
    jmp .loop

.done:
    popa
    ret

;=============================================================================;
; vga_text_move_cursor                                                        ;
;    - Update the hardware cursor                                             ;
;=============================================================================;
vga_text_move_cursor:
    pusha

    mov byte bh, [vga_text_cursor_y]
    mov byte bl, [vga_text_cursor_x]

    xor eax, eax
    mov ecx, VGA_TEXT_COLS
    mov al, bh
    mul ecx
    add al, bl
    mov ebx, eax

    mov al, 0x0F        ; Low byte
    mov dx, 0x3D4
    out dx, al

    mov al, bl
    mov dx, 0x3D5
    out dx, al

    xor eax, eax

    mov al, 0x0E        ; High byte
    mov dx, 0x3D4
    out dx, al

    mov al, bh
    mov dx, 0x3D5
    out dx, al

    popa
    ret

;=============================================================================;
; vga_text_clear_screen                                                       ;
;    - Clear the screen                                                       ;
;=============================================================================;
vga_text_clear_screen:
    pusha

    cld
    mov edi, VGA_TEXT_VIDEO_MEMORY
    mov cx, 2000
    mov byte ah, [vga_text_color]
    mov al, ' '
    rep stosw

    mov byte [vga_text_cursor_x], 0
    mov byte [vga_text_cursor_y], 0

    popa
    call vga_text_move_cursor
    ret
