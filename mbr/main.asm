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

org 0x7C00
bits 16

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xFFFF

    sti

    mov byte [boot_device], dl

    mov ah, 8
    int 0x13
    jc disk_error

    and cx, 0x3F
    mov word [sectors_per_track], cx
    movzx dx, dh
    inc dx
    mov word [sides], dx

    mov ax, 1
    call lba_to_hts                     ; Read GPT header

    mov bx, 0x500
    mov ah, 2
    mov al, 14
    int 0x13
    jc disk_error

    cli
    hlt

disk_error:
    mov si, .msg
    call print_string
    xor ax, ax
    int 0x16
    xor ax, ax
    int 0x19

    .msg db "Disk error. Press any key to reboot...", 13, 10, 0

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

lba_to_hts:
    push bx
    push ax

    mov bx, ax

    xor dx, dx
    div word [sectors_per_track]
    inc dl
    mov cl, dl
    mov ax, bx

    xor dx, dx
    div word [sectors_per_track]
    xor dx, dx
    div word [sides]
    mov dh, dl
    mov ch, al

    pop ax
    pop bx

    mov byte dl, [boot_device]

    ret

boot_device db 0
sectors_per_track dw 0
sides dw 0

times 446 - ($-$$) db 0

db 0            ; Boot indicator

db 0            ; Starting CHS
db 2
db 0

db 0xEE         ; OS type

db 0xFF         ; Ending CHS
db 0xFF
db 0xFF

dd 1            ; Starting LBA

dd 0xFFFFFFFF   ; Size in LBA

times 510 - ($-$$) db 0

dw 0xAA55