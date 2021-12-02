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

elf_address dd 0
elf_class db 0
elf_encoding db 0
elf_type dw 0
elf_machine dw 0
elf_entry dq 0
elf_phoff dq 0
elf_shoff dq 0
elf_phnum dw 0
elf_shnum dw 0
elf_phentsize dd 0

struc ELF64Header
    .ident              resb 16
    .type               resw 1
    .machine            resw 1
    .version            resd 1
    .entry              resq 1
    .phoff              resq 1
    .shoff              resq 1
    .flags              resd 1
    .ehsize             resw 1
    .phentsize          resw 1
    .phnum              resw 1
    .shentsize          resw 1
    .shnum              resw 1
    .shstrndx           resw 1
endstruc

struc ELF64ProgramHeader
    .type               resd 1
    .flags              resd 1
    .offset             resq 1
    .vaddr              resq 1
    .paddr              resq 1
    .filesz             resq 1
    .memsz              resq 1
    .align              resq 1
endstruc

;=============================================================================;
; elf_execute                                                                 ;
;    - Load and execute a kernel ELF image                                    ;
;    @param EDI = Address of image                                            ;
;    @param EDX = Load address                                                ;
;=============================================================================;
elf_execute:
    mov dword [elf_address], edi
    
    mov esi, .elf_header_text
    call vga_text_print_string
    
    mov esi, edi
    
    cmp dword [esi], 0x464C457F
    jne elf_corrupt
    
    mov byte al, [esi+ELF64Header.ident+4]
    mov byte [elf_class], al
    
    mov byte al, [esi+ELF64Header.ident+5]
    mov byte [elf_encoding], al
    
    mov word ax, [esi+ELF64Header.type]
    mov word [elf_type], ax
    
    mov word ax, [esi+ELF64Header.machine]
    mov word [elf_machine], ax
    
    mov dword eax, [esi+ELF64Header.entry]
    mov dword [elf_entry], eax
    
    mov dword eax, [esi+ELF64Header.phoff]
    mov dword [elf_phoff], eax
    
    mov dword eax, [esi+ELF64Header.shoff]
    mov dword [elf_shoff], eax
    
    mov word ax, [esi+ELF64Header.phnum]
    mov word [elf_phnum], ax
    
    mov word ax, [esi+ELF64Header.shnum]
    mov word [elf_shnum], ax
    
    mov word ax, [esi+ELF64Header.phentsize]
    mov word [elf_phentsize], ax
    
    ;call elf_print_class
    ;call elf_print_encoding
    ;call elf_print_type
    
    mov esi, .entry_point_text
    call vga_text_print_string
    
    mov dword eax, [elf_entry]
    call int_to_hex
    mov esi, eax
    call vga_text_print_string
    mov al, 0x0A
    call vga_text_put_char
    
    mov esi, .phoff_text
    call vga_text_print_string
    
    mov dword eax, [elf_phoff]
    call int_to_hex
    mov esi, eax
    call vga_text_print_string
    mov al, 0x0A
    call vga_text_put_char
    
    mov esi, .shoff_text
    call vga_text_print_string
    
    mov dword eax, [elf_shoff]
    call int_to_hex
    mov esi, eax
    call vga_text_print_string
    mov al, 0x0A
    call vga_text_put_char
    
    mov esi, .phnum_text
    call vga_text_print_string
    
    xor eax, eax
    mov word ax, [elf_phnum]
    call int_to_hex
    mov esi, eax
    call vga_text_print_string
    mov al, 0x0A
    call vga_text_put_char
    
    mov esi, .shnum_text
    call vga_text_print_string
    
    xor eax, eax
    mov word ax, [elf_shnum]
    call int_to_hex
    mov esi, eax
    call vga_text_print_string
    mov al, 0x0A
    call vga_text_put_char
    
    mov dword esi, [elf_address]
    add dword esi, [elf_phoff]
    
    xor ecx, ecx
    mov word cx, [elf_phnum]
    
.next_segment:
    test ecx, ecx
    jz .done
    
    push ecx
    push esi
    
    mov dword edi, [esi+ELF64ProgramHeader.paddr]
    mov dword eax, [esi+ELF64ProgramHeader.offset]
    mov dword ecx, [esi+ELF64ProgramHeader.filesz]
    
    mov dword esi, [elf_address]
    add esi, eax
    rep movsb
    
    pop esi
    pop ecx
    
    dec ecx
    add dword esi, [elf_phentsize]
    jmp .next_segment

.done:
    cli
    mov eax, 0x36D76289
    lidt [idt_old]
    jmp [elf_entry]
    
    .elf_header_text db "Kernel ELF64 Header:", 13, 10, 0
    .entry_point_text db "Kernel entry point: 0x", 0
    .phoff_text db "Kernel program header offset: 0x", 0
    .shoff_text db "Kernel section header offset: 0x", 0
    .phnum_text db "Kernel program header entry count: 0x", 0
    .shnum_text db "Kernel section header entry count: 0x", 0

elf_print_class:
    cmp byte [elf_class], 1
    je .class32
    
    cmp byte [elf_class], 2
    je .class64
    
    lea dword esi, [.unknown_text]
    call vga_text_print_string
    ret
    
.class32:
    lea dword esi, [.class32_text]
    call vga_text_print_string
    ret

.class64:
    lea dword esi, [.class64_text]
    call vga_text_print_string
    ret
    
    .unknown_text db "ELF: Unknown class.", 13, 10, 0
    .class32_text db "ELF: 32-Bit Object", 13, 10, 0
    .class64_text db "ELF: 64-Bit Object", 13, 10, 0

elf_print_encoding:
    cmp byte [elf_encoding], 1
    je .le
    
    cmp byte [elf_encoding], 2
    je .be
    
    lea dword esi, [.unknown_text]
    call vga_text_print_string
    ret

.le:
    lea dword esi, [.le_text]
    call vga_text_print_string
    ret

.be:
    lea dword esi, [.be_text]
    call vga_text_print_string
    ret
    
    .unknown_text db "ELF: Unknown encoding", 13, 10, 0
    .le_text db "ELF: Encoding type is little-endian", 13, 10, 0
    .be_text db "ELF: Encoding type is big-endian", 13, 10, 0

elf_print_type:
    cmp byte [elf_type], 1
    je .reloc
    
    cmp byte [elf_type], 2
    je .exec
    
    cmp byte [elf_type], 3
    je .shared
    
    cmp byte [elf_type], 4
    je .core
    
    lea dword esi, [.unknown_text]
    call vga_text_print_string
    ret
    
.reloc:
    lea dword esi, [.reloc_text]
    call vga_text_print_string
    ret

.exec:
    lea dword esi, [.exec_text]
    call vga_text_print_string
    ret

.shared:
    lea dword esi, [.shared_text]
    call vga_text_print_string
    ret

.core:
    lea dword esi, [.core_text]
    call vga_text_print_string
    ret
    
    .unknown_text db "ELF: Type is unknown", 13, 10, 0
    .reloc_text db "ELF: Object is relocatable", 13, 10, 0
    .exec_text db "ELF: Object is an executable file", 13, 10, 0
    .shared_text db "ELF: Object is a shared library", 13, 10, 0
    .core_text db "ELF: Object is a core file", 13, 10, 0

elf_corrupt:
    mov esi, .msg
    call vga_text_print_string
    
    jmp $
    
    .msg db "Kernel ELF image is corrupt. Please reinstall the system.", 13, 10, 0