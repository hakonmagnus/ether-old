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

extern vga_text_print_string

section .data
global idt_data
global idt_pointer

idt_data:
    times 16 * 256 db 0

idt_pointer:
    dw $ - idt_data - 1
    dq idt_data

test_text db "test", 0

section .text
global idt_set_gate
global idt_init
global isr0

idt_init:
    mov rdi, 0
    lea qword rsi, [isr0]
    mov rdx, 0x08
    mov rcx, 0x8E00
    call idt_set_gate
    
    lidt [idt_pointer]
    ret

;=============================================================================;
; idt_set_gate                                                                ;
;    - Set an interrupt gate                                                  ;
;    @param RDI = Index                                                       ;
;    @param RSI = Base                                                        ;
;    @param RDX = Selector                                                    ;
;    @param RCX = Flags                                                       ;
;=============================================================================;
idt_set_gate:
    push rbx
    push rdx
    
    mov rax, rdi
    mov rbx, 16
    mul rbx
    
    mov rdi, idt_data
    add rdi, rax
    
    mov rax, rsi
    
    pop rdx
    
    mov word [rdi], ax
    shr rax, 16
    mov word [rdi+6], ax
    shr rax, 16
    mov dword [rdi+8], eax
    
    mov word [rdi+2], dx
    mov word [rdi+4], cx
    
    pop rbx
    ret

isr0:
    cli
    lea qword rdi, [test_text]
    call vga_text_print_string
    hlt