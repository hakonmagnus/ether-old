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

;=============================================================================;
; gdt_install                                                                 ;
;    - Install the temporary global descriptor table                          ;
;=============================================================================;
gdt_install:
    cli
    pusha
    lgdt [gdt_end]
    sti
    popa
    ret

gdt_start:
    ; Null descriptor
    dd 0
    dd 0

    ; Code descriptor
    dw 0xFFFF       ; Limit low
    dw 0            ; Base low
    db 0            ; Base middle
    db 10011010b    ; Access
    db 11001111b    ; Granularity
    db 0            ; Base high

    ; Data descriptor
    dw 0xFFFF       ; Limit low
    dw 0            ; Base low
    db 0            ; Base middle
    db 10010010b    ; Access
    db 11001111b    ; Granularity
    db 0            ; Base high

gdt_end:
    dw gdt_end - gdt_start - 1      ; Limit
    dd gdt_start                    ; Base
