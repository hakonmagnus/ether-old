org 0

start:
    cli
    
    mov ax, 0x07C0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xFFFF

    sti
    
    mov si, .msg
    call print_string

    cli
    hlt
    
    .msg db "Ether v1.0.0 Celeritas Legacy Boot", 0

print_string:
    pusha
    mov ah, 0x0E

.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop

.done:
    popa
    ret    
    
times 2048 - ($-$$) db 0
