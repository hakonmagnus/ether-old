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

%define KERNEL_ADDRESS 0x100000

;=============================================================================;
; loader32                                                                    ;
;    - Loader 32-bit entry point                                              ;
;=============================================================================;
loader32:
    cli
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000

    call vga_text_clear_screen

    mov byte [vga_text_color], 0x3F
    lea dword esi, [welcome_text]
    call vga_text_print_string

    call idt_initialize
    call pic_remap

    mov byte [vga_text_color], 0x0F
    lea dword esi, [idt_text]
    call vga_text_print_string
    sti

    lea dword esi, [memory_size_text]
    call vga_text_print_string

    xor eax, eax
    xor edx, edx
    mov word ax, [memory_high]
    mov ebx, 64
    mul ebx

    add eax, 1024
    add word ax, [memory_low]

    call int_to_string
    mov esi, eax
    call vga_text_print_string

    mov al, 0x0A
    call vga_text_put_char

    lea dword esi, [memory_map_text]
    call vga_text_print_string

    mov esi, MEMORY_MAP
    xor ecx, ecx

.loop:
    cmp dword [esi+16], 4
    jna .cont1

    mov dword [esi+16], 1

.cont1:
    cmp ecx, 0
    je .cont2

    cmp dword [esi], 0
    je .done1

.cont2:
    push esi

    lea dword esi, [region_start_text]
    call vga_text_print_string

    pop esi

    mov dword eax, [esi+4]
    call int_to_hex
    
    push esi
    mov esi, eax
    call vga_text_print_string
    pop esi

    mov dword eax, [esi]
    call int_to_hex

    push esi
    mov esi, eax
    call vga_text_print_string

    mov esi, region_length_text
    call vga_text_print_string
    pop esi

    mov dword eax, [esi+12]
    call int_to_hex

    push esi
    mov esi, eax
    call vga_text_print_string
    pop esi

    mov dword eax, [esi+8]
    call int_to_hex

    push esi
    mov esi, eax
    call vga_text_print_string

    mov esi, region_type_text
    call vga_text_print_string
    pop esi

    mov eax, [esi+16]
    dec eax
    call int_to_string

    push esi
    mov esi, eax
    call vga_text_print_string
    pop esi

    mov al, 0x0A
    call vga_text_put_char
    
    inc ecx
    add esi, 24
    cmp ecx, 15
    jne .loop

.done1:
    lea dword esi, [atapio_text]
    call vga_text_print_string
    
    lea dword esi, [ata_lba_read]
    mov dword [disk_read_sector], esi
    
    lea dword esi, [ata_lba_write]
    mov dword [disk_write_sector], esi
    
    call ebfs_init
    
    test eax, eax
    jnz ebfs_error
    
    lea dword esi, [ebfs_text]
    call vga_text_print_string
    
    jmp $

ebfs_error:
    mov esi, .msg
    call vga_text_print_string
    jmp $
    
    .msg db "EBFS file system error.", 13, 10, 0

welcome_text db "                           [ Ether OS Loader ", ETHER_VERSION_STRING, " ]                           ", 13, 10, 13, 10, 0
idt_text db "Initialized interrupt vectors", 13, 10, 0
memory_size_text db "Installed memory in KiB: ", 0
memory_map_text db "Physical memory map:", 13, 10, 0
region_start_text db "Region start: ", 0
region_length_text db 9, "Region length: ", 0
region_type_text db 9, "Region type: ", 0
atapio_text db "Using ATA PIO mode", 13, 10, 0
ebfs_text db "Initialized EBFS", 13, 10, 0

disk_read_sector dd 0
disk_write_sector dd 0

%include "./loader/lib/string.asm"
%include "./loader/cpu/idt.asm"
%include "./loader/apic/pic.asm"
%include "./loader/video/vgatext.asm"
%include "./loader/disk/atapio.asm"
%include "./loader/fs/ebfs.asm"
