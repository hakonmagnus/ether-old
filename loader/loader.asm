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

    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x8:loader32

%include "./loader/rm/a20.asm"
%include "./loader/rm/gdt.asm"
%include "./loader/loader32.asm"
