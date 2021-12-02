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

extern vga_text_clear_screen
extern vga_text_print_string
extern sse_init
extern idt_init

section .text
global main

;=============================================================================;
; main                                                                        ;
;    - Ether kernel main                                                      ;
;=============================================================================;
main:
    mov esp, 0xF0000
    
    call sse_init

.no_avx:
    call vga_text_clear_screen
    
    lea qword rdi, [ether_text]
    call vga_text_print_string
    
    lea qword rdi, [idt_text]
    call vga_text_print_string
    
    call idt_init
    int 0

    hlt

section .data
ether_text db "Ether Operating System Initializing...", 13, 10, 0
idt_text db "Setting up interrupts...", 13, 10, 0