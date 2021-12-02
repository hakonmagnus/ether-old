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
; ata_lba_read_c                                                              ;
;    - Read multiple sectors using ATA PIO mode                               ;
;    @param EAX = LBA address                                                 ;
;    @param ECX = Sector count                                                ;
;    @param EDI = Buffer address                                              ;
;=============================================================================;
ata_lba_read_c:
    pusha
    dec ecx
    
.loop:
    call ata_lba_read
    inc eax
    add edi, 0x200
    loop .loop
    
    popa
    ret

;=============================================================================;
; ata_lba_read                                                                ;
;    - Read from disk using ATA PIO mode                                      ;
;    @param EAX = LBA address                                                 ;
;    @param EDI = Buffer address                                              ;
;=============================================================================;
ata_lba_read:
    pushf
    pusha
    
    and eax, 0x0FFFFFFF
    mov ebx, eax
    mov ecx, 1
    
    mov edx, 0x1F6
    shr eax, 24
    or al, 11100000b
    out dx, al
    
    mov edx, 0x1F2
    mov al, cl
    out dx, al
    
    mov edx, 0x1F3
    mov eax, ebx
    out dx, al
    
    mov edx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al
    
    mov edx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al
    
    mov edx, 0x1F7
    mov al, 0x20
    out dx, al
    
.loop:
    in al, dx
    test al, 8
    jz .loop
    
    mov eax, 256
    ;xor bx, bx
    ;mov bl, cl
    ;mul bx
    mov ecx, 256
    mov edx, 0x1F0
    rep insw
    
    popa
    popf
    ret

;=============================================================================;
; ata_lba_write                                                               ;
;    - Write to disk using ATA PIO mode                                       ;
;    @param EAX = LBA address                                                 ;
;    @param EDI = Buffer address                                              ;
;=============================================================================;
ata_lba_write:
    pushf
    pusha
    and eax, 0x0FFFFFFF
    mov ecx, 1
    
    mov edx, 0x1F6
    shr eax, 24
    or al, 11100000b
    out dx, al
    
    mov edx, 0x1F2
    mov al, cl
    out dx, al
    
    mov edx, 0x1F3
    mov eax, ebx
    out dx, al
    
    mov edx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al
    
    mov edx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al
    
    mov edx, 0x1F7
    mov al, 0x30
    out dx, al
    
.loop:
    in al, dx
    test al, 8
    jz .loop
    
    mov eax, 256
    ;xor bx, bx
    ;mov bl, cl
    ;mul bx
    mov ecx, 256
    mov edx, 0x1F0
    mov esi, edi
    rep outsw
    
    popa
    popf
    ret