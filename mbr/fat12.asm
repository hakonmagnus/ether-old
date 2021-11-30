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

jmp short start
nop

oem_name                    db "ETHEREFI"
bytes_per_sector            dw 512
sectors_per_cluster         db 4
reserved_sectors            dw 1
number_of_fats              db 2
max_root_entries            dw 512
total_sectors               dw 1000
media_descriptor            db 0xF8
sectors_per_fat             dw 2
sectors_per_track           dw 0x20
number_of_heads             dw 0x40
hidden_sectors              dd 0
total_sectors_big           dd 0
drive_number                db 0x80
reserved                    db 0
extended_signature          db 0x29
volume_id                   dd 0xE14E6F0F   ; Random
volume_label                db "NO NAME    "
file_system                 db "FAT12   "

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

    mov si, message
    call print_string

    xor ax, ax
    int 0x16
    xor ax, ax
    int 0x19

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

message db "This is not a bootable partition. Press any key to reboot...", 13, 10, 0

times 510 - ($-$$) db 0
dw 0xAA55
