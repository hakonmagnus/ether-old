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

org 0x500
bits 16

%include "./version.asm"
%define MEMORY_MAP  0x8000

;=============================================================================;
; start                                                                       ;
;    - Legacy loader 16-bit entry point                                       ;
;=============================================================================;
start:
    cli
    
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xFFFF

    sti
    
    call a20_enable
    call gdt_install

    xor eax, eax
    xor ebx, ebx
    call bios_get_memory_size

    xor eax, eax
    mov ds, ax
    mov di, MEMORY_MAP
    call bios_get_memory_map

    mov word [memory_high], bx
    mov word [memory_low], ax

    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x8:loader32

memory_high dw 0
memory_low  dw 0

%include "./loader/rm/a20.asm"
%include "./loader/rm/gdt.asm"
%include "./loader/rm/memory.asm"
%include "./loader/loader32.asm"
