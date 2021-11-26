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

bits 16
org 0

start:
    mov ax, 0x07C0
    add ax, 512
    cli
    mov ss, ax
    mov sp, 4096
    sti

    mov ax, 0x07C0
    mov ds, ax

    mov si, .msg
    call print_string

    cli
    hlt

    .msg db "Ether Installer v1.0.0", 13, 10, 0

print_string:
    pusha
    mov ah, 0x0E

.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop

.done:
    popa
    ret

times 510-($-$$) db 0
dw 0xAA55
