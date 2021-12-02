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

section .entry
global _start
extern multiboot_info
extern gdt_end
extern main

bits 32

;=============================================================================;
; _start                                                                      ;
;    - 32-bit entry point                                                     ;
;    @param EAX = Magic                                                       ;
;    @param EBX = Pointer to multiboot info struct                            ;
;=============================================================================;
_start:
    mov dword [multiboot_info], ebx
    
    ; Check for CPUID
    
    pushfd
    pop eax
    
    mov ecx, eax
    
    xor eax, 1 << 21
    
    push eax
    popfd
    
    pushfd
    pop eax
    
    push ecx
    popfd
    
    xor eax, ecx
    jz error
    
    ; Check for long mode (required for Ether)
    
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb error            ; No long mode
    
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz error            ; No long mode
    
    ; Identity map first 4MB of physical memory
    
    mov edi, 0x1000     ; PML4T
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3
    
    mov dword [edi], 0x2003     ; Pointer to PDPT
    add edi, 0x1000
    
    mov dword [edi], 0x3003     ; Pointer to PDT
    add edi, 0x1000
    
    mov dword [edi], 0x4003     ; Pointer to PT
    add edi, 0x1000
    
    mov ebx, 3
    mov ecx, 1024

.set_entry:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop .set_entry
    
    ; Enable PAE paging
    
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    
    ; Set LM bit
    
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    
    ; Enable paging
    
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    ;== COMPATABILITY MODE ==;
    
    lgdt [gdt_end]
    jmp 0x8:long_mode
    
error:
    cli
    hlt

bits 64

long_mode:
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    jmp main