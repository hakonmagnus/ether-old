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
org 0x7C00

;=============================================================================;
; entry                                                                       ;
;    - ISO loader entry point                                                 ;
;=============================================================================;
entry:
    jmp 0x0:start
    times 8-($-$$) db 0

bi_primary_volume_descriptor    dd 0            ; LBA of primary volume descriptor
bi_boot_file_location           dd 0            ; LBA of boot file
bi_boot_file_length             dd 0            ; Length of boot file
bi_checksum                     dd 0            ; 32-bit checksum
bi_reserved                     times 40 db 0   ; Reserved

;=============================================================================;
; start                                                                       ;
;    - ISO loader main                                                        ;
;=============================================================================;
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

    lea word si, [welcome]
    call print_string

    mov si, buffer
    mov byte [si], 0x10
    mov byte [si+1], 0
    mov word [si+2], 1
    mov word [si+4], buffer
    mov word [si+6], 0
    
    mov word ax, [bi_primary_volume_descriptor]
    mov word [si+8], ax
    mov word ax, [bi_primary_volume_descriptor + 2]
    mov word [si+10], ax
    mov word [si+12], 0
    mov word [si+14], 0

    mov ah, 0x42
    int 0x13
    jc disk_error

    cmp byte [si], 1
    jne disk_error

    mov di, buffer

    mov byte [di], 0x10
    mov byte [di+1], 0
    mov word [di+2], 1
    mov word [di+4], buffer
    mov word [di+6], 0
    mov word ax, [si+0x9E]
    mov word [di+8], ax
    mov word ax, [si+0xA0]
    mov word [di+10], ax
    mov word [di+12], 0
    mov word [di+14], 0
    mov si, buffer

    mov ah, 0x42
    mov byte dl, [boot_device]
    int 0x13
    jc disk_error

    mov si, buffer

.next_entry:
    cmp byte [si], 0
    je not_found

    push si

    mov di, si
    add di, 33

    cmp byte [di], 0
    je .skip_entry

    cmp byte [di], 1
    je .skip_entry

    mov byte cl, [si+32]
    lea word si, [boot_filename]
    call string_compare

    pop si

    jc .found

.skip_entry:
    xor ax, ax
    mov byte al, [si]
    add si, ax
    jmp .next_entry

.found:
    mov di, buffer

    mov byte [di], 0x10
    mov byte [di+1], 0
    mov word [di+2], 1
    mov word [di+4], buffer
    mov word [di+6], 0
    mov word ax, [si+2]
    mov word [di+8], ax
    mov word ax, [si+4]
    mov word [di+10], ax
    mov word [di+12], 0
    mov word [di+14], 0
    mov si, buffer

    mov ah, 0x42
    mov byte dl, [boot_device]
    int 0x13
    jc disk_error

    mov si, buffer

.next_entry_2:
    cmp byte [si], 0
    je not_found

    push si

    mov di, si
    add di, 33

    cmp byte [di], 0
    je .skip_entry_2

    cmp byte [di], 1
    je .skip_entry_2

    mov byte cl, [si+32]
    lea word si, [loader_filename]
    call string_compare

    pop si

    jc .found_2

.skip_entry_2:
    xor ax, ax
    mov byte al, [si]
    add si, ax
    jmp .next_entry_2

.found_2:
    mov di, buffer

    mov byte [di], 0x10
    mov byte [di+1], 0
    mov word [di+2], 8
    mov word [di+4], 0x500
    mov word [di+6], 0
    mov word ax, [si+2]
    mov word [di+8], ax
    mov word ax, [si+4]
    mov word [di+10], ax
    mov word [di+12], 0
    mov word [di+14], 0
    mov si, buffer

    mov ah, 0x42
    mov byte dl, [boot_device]
    int 0x13
    jc disk_error

    jmp 0x0:0x500

;=============================================================================;
; disk_error                                                                  ;
;    - Called when the disk cannot be read                                    ;
;=============================================================================;
disk_error:
    lea word si, [.msg]
    call print_string
    xor ax, ax
    int 0x16
    xor ax, ax
    int 0x19

    .msg db "Disk error. Press any key to reboot...", 13, 10, 0

;=============================================================================;
; not_found                                                                   ;
;    - Called when the loader is not found on the disk                        ;
;=============================================================================;
not_found:
    lea word si, [.msg]
    call print_string
    xor ax, ax
    int 0x16
    xor ax, ax
    int 0x19

    .msg db "Ether loader not found. Press any key to reboot...", 13, 10, 0

;=============================================================================;
; print_string                                                                ;
;    - Print a string to the console                                          ;
;    @param SI = Pointer to string                                            ;
;=============================================================================;
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

;=============================================================================;
; string_compare                                                              ;
;    - Compare two strings                                                    ;
;    @param SI = String one                                                   ;
;    @param DI = String two                                                   ;
;    @param CL = Number of characters                                         ;
;    @return CF = Set if equal                                                ;
;=============================================================================;
string_compare:
    pusha
    mov ch, 0

.loop:
    cmp ch, cl
    je .done

    mov byte al, [si]
    mov byte bl, [di]

    cmp al, bl
    jne .not_same

    cmp al, 0
    je .done

    inc ch
    inc si
    inc di
    jmp .loop

.not_same:
    popa
    clc
    ret

.done:
    popa
    stc
    ret

welcome db "Hello", 13, 10, 0
boot_filename db "BOOT", 0
loader_filename db "LOADER.BIN;1", 0

boot_device                 db 0    ; BIOS boot device
root_directory_0            dw 0    ; First word of root directory
root_directory_1            dw 0    ; Second word of root directory
root_directory_2            dw 0    ; Third word of root directory
root_directory_3            dw 0    ; Fourth word of root directory

buffer:
