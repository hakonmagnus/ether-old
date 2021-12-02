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

%define KERNEL_ADDRESS 0x100000

org KERNEL_ADDRESS
bits 32

section .header     progbits
section .entry      progbits    follows=.header     align=4096
section .entry64    progbits    follows=.entry      align=4096
section .multiboot  progbits    follows=.entry64    align=4096
section .text       progbits    follows=.multiboot  align=4096
section .rodata     progbits    follows=.text       align=4096
section .data       progbits    follows=.rodata     align=4096
section .strtab     progbits    follows=.data       align=4096
section .secheader  progbits    follows=.strtab     align=4096
section .bss        nobits      follows=.secheader

section .header
elf_ident:
    db 0x7F                         ; Magic
    db 'E'
    db 'L'
    db 'F'
    db 2                            ; Class is 64-bit
    db 1                            ; Encoding is little-endian
    db 0                            ; ABI
    db 0                            ; ABI version
    dq 0
    
elf_header:
    dw 2                            ; Type is executable file
    dw 62                           ; Machine type
    dd 1                            ; Version
    dq entry_start                  ; Entry point address
    dq program_header - KERNEL_ADDRESS    ; Program header offset
    dq section_header - KERNEL_ADDRESS    ; Section header offset
    dd 0                            ; Flags
    dw 0x40                         ; ELF header size
    dw 56                           ; Program header entry size
    dw 3                            ; Number of program header entries
    dw 64                           ; Section header entry size
    dw 7                            ; Number of section header entries
    dw 6                            ; Section name string table index

program_header:
    ; Entry LOAD
    dd 1                            ; Type
    dd 1 | 4                        ; Flags
    dq entry_start - KERNEL_ADDRESS ; Offset in file
    dq entry_start                  ; Virtual address
    dq entry_start                  ; Physical address
    dq entry_length                 ; Size in file
    dq entry_length                 ; Size in memory
    dq 4096                         ; Alignment
    
    ; Entry 64-bit ELF LOAD
    dd 1                            ; Type
    dd 1 | 4                        ; Flags
    dq entry64_start - KERNEL_ADDRESS ; Offset in file
    dq entry64_start                ; Virtual address
    dq entry64_start                ; Physical address
    dq entry64_length               ; Size in file
    dq entry64_length               ; Size in memory
    dq 4096                         ; Alignment
    
    ; Rest of ELF LOAD
    dd 1                            ; Type
    dd 1 | 2 | 4                    ; Flags
    dq multiboot_start - KERNEL_ADDRESS  ; Offset in file
    dq multiboot_start              ; Physical address
    dq multiboot_start              ; Virtual address
    dq multiboot_length + text_length + rodata_length + data_length ; Size in file
    dq multiboot_length + text_length + rodata_length + data_length ; Size in memory
    dq 4096                         ; Alignment
    
section .secheader
section_header:
    ; Entry section
    dd string_table.entry - string_table ; Name
    dd 1                            ; Type
    dq 4 | 2                        ; Flags
    dq entry_start                  ; Virtual address
    dq entry_start - KERNEL_ADDRESS       ; Offset in file
    dq entry_length                 ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; 64-bit EFI entry section
    dd string_table.entry64 - string_table ; Name
    dd 1                            ; Type
    dq 4 | 2                        ; Flags
    dq entry64_start                ; Virtual address
    dq entry64_start - KERNEL_ADDRESS     ; Offset in file
    dq entry64_length               ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; Multiboot section
    dd string_table.multiboot - string_table ; Name
    dd 1                            ; Type
    dq 2                            ; Flags
    dq multiboot_start              ; Virtual address
    dq multiboot_start - KERNEL_ADDRESS   ; Offset in file
    dq multiboot_length             ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; Text section
    dd string_table.text - string_table ; Name
    dd 1                            ; Type
    dq 2 | 4                        ; Flags
    dq text_start                   ; Virtual address
    dq text_start - KERNEL_ADDRESS  ; Offset in file
    dq text_length                  ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; Rodata section
    dd string_table.rodata - string_table ; Name
    dd 1                            ; Type
    dq 2                            ; Flags
    dq rodata_start                 ; Virtual address
    dq rodata_start - KERNEL_ADDRESS    ; Offset in file
    dq rodata_length                ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; Data section
    dd string_table.data - string_table ; Name
    dd 1                            ; Type
    dq 2 | 1                        ; Flags
    dq data_start                   ; Virtual address
    dq data_start - KERNEL_ADDRESS  ; Offset in file
    dq data_length                  ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; String table section
    dd string_table.strtab - string_table ; Name
    dd 3                            ; Type
    dq 0                            ; Flags
    dq 0                            ; Virtual address
    dq strtab_start - KERNEL_ADDRESS    ; Offset in file
    dq strtab_length                ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size
    
    ; BSS section
    dd string_table.bss - string_table ; Name
    dd 1                            ; Type
    dq 1                            ; Flags
    dq 0                            ; Virtual address
    dq bss_start - KERNEL_ADDRESS   ; Offset in file
    dq bss_length                   ; Size
    dd 0                            ; Link to other section
    dd 0                            ; Info
    dq 4096                         ; Align
    dq 0                            ; Entry size

%include "./ether/multiboot.asm"
%include "./ether/entry.asm"
%include "./ether/entry64.asm"

section .strtab
string_table:
    .entry db ".entry", 0
    .entry64 db ".entry64", 0
    .multiboot db ".multiboot", 0
    .text db ".text", 0
    .rodata db ".rodata", 0
    .data db ".data", 0
    .strtab db ".strtab", 0
    .bss db ".bss", 0

section .header
  header_start  equ  $$
  header_length  equ  $-$$

section .entry
  entry_start  equ  $$
  entry_length  equ  $-$$

section .entry64
  entry64_start  equ  $$
  entry64_length  equ  $-$$

section .multiboot
  multiboot_start  equ  $$
  multiboot_length  equ  $-$$

section .text
  text_start  equ  $$
  text_length  equ  $-$$

section .rodata
  rodata_start  equ  $$
  rodata_length  equ  $-$$

section .data
  data_start  equ  $$
  data_length  equ  $-$$

section .strtab
  strtab_start  equ  $$
  strtab_length  equ  $-$$

section .secheader
  secheader_start  equ  $$
  secheader_length  equ  $-$$

section .bss
  bss_start  equ  $$
  bss_length  equ  $-$$