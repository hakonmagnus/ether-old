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

    jmp $

welcome_text db "                           [ Ether OS Loader v1.0.0 ]                           ", 13, 10, 13, 10, 0
idt_text db "Initialized interrupt vectors", 13, 10, 0

%include "./loader/cpu/idt.asm"
%include "./loader/apic/pic.asm"
%include "./loader/video/vgatext.asm"
