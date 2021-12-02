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

ebfs_start_lba dd 0

;=============================================================================;
; ebfs_init                                                                   ;
;    - Initialize EBFS driver                                                 ;
;=============================================================================;
ebfs_init:
    pusha
    mov dword [.return], 0
    
    mov eax, 1
    mov cl, 1
    mov edi, KERNEL_ADDRESS
    call [disk_read_sector]
    
    mov esi, KERNEL_ADDRESS
    
    cmp dword [esi], 0x20494645
    jne .error
    
    cmp dword [esi+4], 0x54524150
    jne .error
    
    mov dword ebx, [esi+0x50]
    mov dword eax, [esi+0x48]
    
    mov cl, 32
    mov edi, KERNEL_ADDRESS
    call [disk_read_sector]
    
    mov ecx, ebx
    mov esi, KERNEL_ADDRESS

.next_entry:
    cmp dword [esi], 0x1B64A89C
    jne .skip_entry
    
    cmp dword [esi+4], 0xD04A0B29
    jne .skip_entry
    
    cmp dword [esi+8], 0x550C3595
    jne .skip_entry
    
    cmp dword [esi+12], 0xC6018A3D
    jne .skip_entry
    
    mov dword eax, [esi+0x20]
    mov dword [ebfs_start_lba], eax
    
    jmp .done
    
.skip_entry:
    add esi, 0x80
    loop .next_entry
    
.error:
    mov dword [.return], 1
    
.done:
    popa
    mov dword eax, [.return]
    ret
    
    .return dd 0