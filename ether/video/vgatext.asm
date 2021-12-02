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

%define VGA_TEXT_VIDEO_MEMORY       0xB8000
%define VGA_TEXT_COLS               80
%define VGA_TEXT_LINES              25

section .data
vga_text_color                      db 0x0F
vga_text_cursor_x                   db 0
vga_text_cursor_y                   db 0

section .text
global vga_text_clear_screen
global vga_text_print_string
global vga_text_put_char

;=============================================================================;
; vga_text_put_char                                                           ;
;    - Print a single character                                               ;
;    @param RDI = ASCII Character                                             ;
;=============================================================================;
vga_text_put_char:
    push rbx
    
    mov rax, rdi
    
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
    xor rax, rax
    
    mov rcx, VGA_TEXT_COLS * 2
    mov byte al, [vga_text_cursor_y]
    mul rcx
    push rax
    
    mov byte al, [vga_text_cursor_x]
    mov cl, 2
    mul cl
    pop rcx
    add rax, rcx
    
    mov rdi, VGA_TEXT_VIDEO_MEMORY
    add rdi, rax
    
    mov dl, bl
    mov byte dh, [vga_text_color]
    mov word [rdi], dx
    
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
    jb .done
    
    mov byte [vga_text_cursor_x], 0
    inc byte [vga_text_cursor_y]

.done:
    call vga_text_move_cursor
    pop rbx
    xor rax, rax
    ret

;=============================================================================;
; vga_text_print_string                                                       ;
;    - Print a string                                                         ;
;    @param RDI = Pointer to string                                           ;
;=============================================================================;
vga_text_print_string:
.loop:
    xor rax, rax
    mov byte al, [rdi]
    
    test al, al
    jz .done

    push rdi
    mov rdi, rax
    call vga_text_put_char
    pop rdi
    
    inc rdi
    jmp .loop

.done:
    ret

;=============================================================================;
; vga_text_move_cursor                                                        ;
;    - Update the hardware cursor                                             ;
;=============================================================================;
vga_text_move_cursor:
    push rbx
    
    mov byte bh, [vga_text_cursor_y]
    mov byte bl, [vga_text_cursor_x]
    
    xor rax, rax
    mov rcx, VGA_TEXT_COLS
    mov al, bh
    mul rcx
    add al, bl
    mov rbx, rax
    
    mov al, 0x0F            ; Low byte
    mov dx, 0x3D4
    out dx, al
    
    mov al, bl
    mov dx, 0x3D5
    out dx, al
    
    xor rax, rax
    
    mov al, 0x0E            ; High byte
    mov dx, 0x3D4
    out dx, al
    
    mov al, bh
    mov dx, 0x3D5
    out dx, al
    
    xor rax, rax
    pop rbx
    ret

;=============================================================================;
; vga_text_clear_screen                                                       ;
;    - Clear the screen                                                       ;
;=============================================================================;
vga_text_clear_screen:
    cld
    mov rdi, VGA_TEXT_VIDEO_MEMORY
    mov rcx, 2000
    mov byte ah, [vga_text_color]
    mov al, ' '
    rep stosw
    
    mov byte [vga_text_cursor_x], 0
    mov byte [vga_text_cursor_y], 0
    
    call vga_text_move_cursor
    
    xor rax, rax
    ret