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
; bios_get_memory_map                                                         ;
;    - Get a map of physical memory (RAM)                                     ;
;    @param ES:DI = Destination buffer                                        ;
;    @return BP = Entry count                                                 ;
;=============================================================================;
bios_get_memory_map:
    pushad

    xor ebx, ebx
    xor bp, bp

    mov edx, 'PAMS'
    mov eax, 0xE820
    mov ecx, 214
    int 0x15
    jc .error

    cmp eax, 'PAMS'
    jne .error

    test ebx, ebx
    je .error

    jmp .start

.next_entry:
    mov edx, 'PAMS'
    mov ecx, 24
    mov eax, 0xE820
    int 0x15

.start:
    jcxz .skip_entry

.notext:
    mov dword ecx, [es:di+8]
    test ecx, ecx
    jne .good_entry
    mov dword ecx, [es:di+12]
    jecxz .skip_entry

.good_entry:
    inc bp
    add di, 24

.skip_entry:
    cmp ebx, 0
    jne .next_entry
    jmp .done

.error:
    stc

.done:
    popad
    ret

;=============================================================================;
; bios_get_memory_size                                                        ;
;    - Get memory size                                                        ;
;    @return AX = KiB Between 1MiB and 16MiB                                  ;
;    @return BX = Number of 64KiB blocks above 16MiB                          ;
;    @return BX = 0 and AX = -1 on error                                      ;
;=============================================================================;
bios_get_memory_size:
    push ecx
    push edx

    xor ecx, ecx
    xor edx, edx
    mov ax, 0xE801
    int 0x15
    jc .error

    cmp ah, 0x86
    je .error
    
    cmp ah, 0x80
    je .error

    jcxz .use_ax

    mov ax, cx
    mov bx, dx

.use_ax:
    pop edx
    pop ecx
    ret

.error:
    mov ax, -1
    mov bx, 0
    pop edx
    pop ecx
    ret
