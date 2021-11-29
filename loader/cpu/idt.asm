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

%macro idt_isr 2
isr_%1:
    cli
    mov byte [vga_text_color], 0x04
    mov esi, .msg
    call vga_text_print_string
    hlt

    .msg db %2, 13, 10, 0
%endmacro

%macro idt_entry 1
    lea dword esi, [idt_start]
    add esi, %1 * 8

    mov eax, isr_%1
    mov word [esi], ax
    shr eax, 16
    mov word [esi+6], ax
    mov byte [esi+2], 0x08
    mov byte [esi+5], 0x8E
%endmacro

;=============================================================================;
; idt_initialize                                                              ;
;    - Initialize interrupt descriptor table                                  ;
;=============================================================================;
idt_initialize:
    pusha

    idt_entry 0
    idt_entry 1
    idt_entry 2
    idt_entry 3
    idt_entry 4
    idt_entry 5
    idt_entry 6
    idt_entry 7
    idt_entry 8
    idt_entry 9
    idt_entry 10
    idt_entry 11
    idt_entry 12
    idt_entry 13
    idt_entry 14
    idt_entry 16
    idt_entry 17
    idt_entry 18
    idt_entry 19
    idt_entry 20
    idt_entry 21
    idt_entry 28
    idt_entry 29
    idt_entry 30

    lidt [idt_end]
    popa
    ret

idt_start:
    times (8 * 256) db 0

idt_end:
    dw idt_end - idt_start - 1  ; Limit
    dd idt_start                ; Base

idt_isr 0, "Division by zero exception."
idt_isr 1, "Debug exception."
idt_isr 2, "Non-maskable interrupt exception."
idt_isr 3, "Breakpoint exception."
idt_isr 4, "Overflow exception."
idt_isr 5, "Bound range exceeded exception."
idt_isr 6, "Invalid opcode exception."
idt_isr 7, "Device not available exception."
idt_isr 8, "Double fault exception."
idt_isr 9, "Coprocessor segment overrun exception."
idt_isr 10, "Invalid TSS exception."
idt_isr 11, "Segment not present exception."
idt_isr 12, "Stack fault exception."
idt_isr 13, "General protection fault exception."
idt_isr 14, "Page fault exception."
idt_isr 16, "x87 floating-point exception."
idt_isr 17, "Alignment check exception."
idt_isr 18, "Machine check exception."
idt_isr 19, "SIMD floating-point exception."
idt_isr 20, "Virtualization exception."
idt_isr 21, "Control protection exception."
idt_isr 28, "Hypervisor injection exception."
idt_isr 29, "VMM communication exception."
idt_isr 30, "Security exception."
