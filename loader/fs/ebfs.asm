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
ebfs_block_size dd 0
ebfs_group_size dd 0
ebfs_total_inodes dd 0
ebfs_inode_size dd 0
ebfs_root_directory dd 0
ebfs_inodes dd 0
ebfs_current_directory dd 0
ebfs_disk_buffer dd 0

;=============================================================================;
; ebfs_read_file                                                              ;
;    - Read a file from the disk                                              ;
;    @param ESI = Filename                                                    ;
;    @param EDI = Destination buffer                                          ;
;    @return EAX = File size                                                  ;
;=============================================================================;
ebfs_read_file:
    pusha
    
    mov dword [.buffer], edi
    mov dword [.filename], esi
    
    mov dword eax, [ebfs_group_size]
    mov dword ebx, [ebfs_block_size]
    mul ebx
    sub eax, 16
    
    xor edx, edx
    mov ebx, 4
    div ebx
    
    mov dword [.group_data_size], eax
    
    mov edi, esi
    mov dword esi, [ebfs_current_directory]
    
.next_entry:
    cmp byte [esi+4], 0
    je .notfound
    
    xor eax, eax
    mov word ax, [esi+6]
    add esi, 8
    
    call string_compare
    jc .found
    
    sub esi, 8
    add esi, eax
    jmp .next_entry

.found:
    sub esi, 8
    
    mov dword eax, [esi]
    mov dword ebx, [ebfs_inode_size]
    mul ebx
    
    push eax
    
    mov dword eax, [ebfs_block_size]
    mov dword ebx, [ebfs_group_size]
    mul ebx
    sub eax, 16
    
    pop ebx
    xor edx, edx
    xchg eax, ebx
    div ebx
    
    add dword eax, [ebfs_inodes]        ; Contains inode group
    add edx, 16                         ; Contains inode offset
    
    mov dword [.offset], edx
    
    mov dword ebx, [ebfs_group_size]
    mul ebx
    
    add dword eax, [ebfs_start_lba]
    mov dword edi, [ebfs_disk_buffer]
    mov dword ecx, [ebfs_group_size]
    call [disk_read_sectors]
    
    mov dword esi, [ebfs_disk_buffer]
    add dword esi, [.offset]
    
    mov dword eax, [esi+0x4]
    mov dword [.size], eax
    
    mov dword eax, [esi+0x14]           ; Group pointer to directory
    mov dword ebx, [ebfs_group_size]
    mul ebx
    
    add dword eax, [ebfs_start_lba]
    mov dword esi, [.buffer]

.next_group:
    mov dword edi, [ebfs_disk_buffer]
    
    mov dword ecx, [ebfs_group_size]
    call [disk_read_sectors]
    mov dword edi, [ebfs_disk_buffer]
    
    cmp byte [edi], 0
    je .done
    
    mov dword eax, [edi+2]
    mov dword [.next_group_address], eax
    
    add edi, 16

    push esi
    
    xchg esi, edi
    
    mov dword ecx, [.group_data_size]
    rep movsd
    
    pop esi
    
    add dword esi, [.group_data_size]
    
    cmp dword [.next_group_address], 0xFFFFFFFF
    je .done
    
    mov dword eax, [.next_group_address]
    jmp .next_group

.done:
    popa
    mov dword eax, [.size]
    ret
    
.notfound:
    popa
    mov eax, -1
    ret
    
    .size dd 0
    .buffer dd 0
    .filename dd 0
    .next_group_address dd 0
    .group_data_size dd 0
    .offset dd 0

;=============================================================================;
; ebfs_cd                                                                     ;
;    - Change working directory                                               ;
;    @param EDI = Directory to enter                                          ;
;    @return CF = Set if not found                                            ;
;=============================================================================;
ebfs_cd:
    pusha
    
    mov dword eax, [ebfs_group_size]
    mov dword ebx, [ebfs_block_size]
    mul ebx
    sub eax, 16
    
    xor edx, edx
    mov ebx, 4
    div ebx
    
    mov dword [.group_data_size], eax
    
    mov dword esi, [ebfs_current_directory]

.next_entry:
    cmp byte [esi+4], 0
    je .notfound

    xor eax, eax
    mov word ax, [esi+0x6]
    add esi, 8
    
    call string_compare
    jc .found
    
    sub esi, 8
    add esi, eax
    jmp .next_entry

.found:
    sub esi, 8
    
    mov dword eax, [esi]
    mov dword ebx, [ebfs_inode_size]
    mul ebx
    
    push eax
    
    mov dword eax, [ebfs_block_size]
    mov dword ebx, [ebfs_group_size]
    mul ebx
    sub eax, 16
    
    pop ebx
    xor edx, edx
    xchg eax, ebx
    div ebx
    
    add dword eax, [ebfs_inodes]        ; Contains inode group
    add edx, 16                         ; Contains inode offset
    
    mov dword [.offset], edx
    
    mov dword ebx, [ebfs_group_size]
    mul ebx
    
    add dword eax, [ebfs_start_lba]
    mov dword edi, [ebfs_disk_buffer]
    mov dword ecx, [ebfs_group_size]
    call [disk_read_sectors]
    
    mov dword esi, [ebfs_disk_buffer]
    add dword esi, [.offset]
    
    mov dword eax, [esi+0x14]           ; Group pointer to directory
    mov dword ebx, [ebfs_group_size]
    mul ebx
    
    add dword eax, [ebfs_start_lba]
    
    mov dword esi, [ebfs_current_directory]
    
.next_group:
    mov dword edi, [ebfs_disk_buffer]
    
    mov dword ecx, [ebfs_group_size]
    call [disk_read_sectors]
    mov dword edi, [ebfs_disk_buffer]
    
    cmp byte [edi], 0
    je .done
    
    mov dword eax, [edi+2]
    mov dword [.next_group_address], eax
    
    add edi, 16

    push esi
    
    xchg esi, edi
    
    mov dword ecx, [.group_data_size]
    rep movsd
    
    pop esi
    
    add dword esi, [.group_data_size]
    
    cmp dword [.next_group_address], 0xFFFFFFFF
    je .done
    
    mov dword eax, [.next_group_address]
    jmp .next_group

.done:
    clc
    popa
    ret
    
.notfound:
    stc
    popa
    ret
    
    .offset dd 0
    .next_group_address dd 0
    .group_data_size dd 0

;=============================================================================;
; ebfs_init                                                                   ;
;    - Initialize EBFS driver                                                 ;
;=============================================================================;
ebfs_init:
    pusha
    mov dword [.return], 0
    
    mov eax, 1
    mov edi, KERNEL_ADDRESS
    call [disk_read_sector]
    
    mov esi, KERNEL_ADDRESS
    
    cmp dword [esi], 0x20494645
    jne .error
    
    cmp dword [esi+4], 0x54524150
    jne .error
    
    mov dword ebx, [esi+0x50]
    mov dword eax, [esi+0x48]
    
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
    inc eax
    
    mov edi, KERNEL_ADDRESS
    call [disk_read_sector]
    
    mov esi, KERNEL_ADDRESS
    
    cmp word [esi], 0xEBF5
    jne .error
    
    mov dword eax, [esi+4]
    mov dword [ebfs_block_size], eax
    
    mov dword eax, [esi+8]
    mov dword [ebfs_group_size], eax
    
    mov dword eax, [esi+0x10]
    mov dword [ebfs_total_inodes], eax
    
    mov dword eax, [esi+0x18]
    mov dword [ebfs_inode_size], eax
    
    mov dword eax, [esi+0x24]
    mov dword [ebfs_root_directory], eax
    
    mov dword eax, [esi+0x28]
    mov dword [ebfs_inodes], eax
    
    mov dword eax, [ebfs_block_size]
    mov dword ebx, [ebfs_group_size]
    mul ebx
    mov ebx, 8
    mul ebx
    push eax
    call mm_alloc
    mov dword [ebfs_current_directory], eax
    
    pop eax
    call mm_alloc
    mov dword [ebfs_disk_buffer], eax
    
    mov dword eax, [ebfs_group_size]
    mov dword ebx, [ebfs_block_size]
    mul ebx
    sub eax, 16
    
    xor edx, edx
    mov ebx, 4
    div ebx
    
    mov dword [.group_data_size], eax
    
    mov dword eax, [ebfs_root_directory]
    mov dword ebx, [ebfs_group_size]
    mul ebx
    
    add dword eax, [ebfs_start_lba]
    
    mov dword esi, [ebfs_current_directory]

.next_group:
    mov dword edi, [ebfs_disk_buffer]
    
    mov dword ecx, [ebfs_group_size]
    call [disk_read_sectors]
    mov dword edi, [ebfs_disk_buffer]
    
    cmp byte [edi], 0x04
    jne .done
    
    mov dword eax, [edi+2]
    mov dword [.next_group_address], eax
    
    add edi, 16

    push esi
    
    xchg esi, edi
    
    mov dword ecx, [.group_data_size]
    rep movsd
    
    pop esi
    
    add dword esi, [.group_data_size]
    
    cmp dword [.next_group_address], 0xFFFFFFFF
    je .done
    
    mov dword eax, [.next_group_address]
    jmp .next_group
    
.skip_entry:
    add esi, 0x80
    
    dec ecx
    test ecx, ecx
    jnz .next_entry
    
.error:
    mov dword [.return], 1
    
.done:
    popa
    mov dword eax, [.return]
    ret
    
    .return dd 0
    .next_group_address dd 0
    .group_data_size dd 0