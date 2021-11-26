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

org 0x100000
bits 64

%define EFI_IMAGE_SUBSYSTEM_EFI_APPLICATION         10
%define EFI_IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER 11
%define EFI_IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER      12

%define EFI_IMAGE_MACHINE_IA32                      0x014C
%define EFI_IMAGE_MACHINE_IA64                      0x0200
%define EFI_IMAGE_MACHINE_EBC                       0x0EBC
%define EFI_IMAGE_MACHINE_x64                       0x8664
%define EFI_IMAGE_MACHINE_ARMTHUMB_MIXED            0x01C2
%define EFI_IMAGE_MACHINE_AARCH64                   0xAA64
%define EFI_IMAGE_MACHINE_RISCV32                   0x5032
%define EFI_IMAGE_MACHINE_RISCV64                   0x5064
%define EFI_IMAGE_MACHINE_RISCV128                  0x5128

section .header
dos_header:
    dw 0x5A4D       ; Magic number
    times 29 dw 0   ; Reserved
    dd 0x00000080   ; Address of PE header

dos_stub:
    times 32 dw 0   ; DOS stub

pe_header:
    dd 0x00004550           ; PE header
    dw EFI_IMAGE_MACHINE_x64 ; Machine architecture
    dw 2                    ; Two sections (.text, .data)
    dd 0x61A0EA9A           ; Current epoch
    dd 0                    ; No symbol table
    dd 0                    ; No symbols in the symbol table
    dw oSize                ; Size of optional header
    dw 0x1002               ; System file

oSize equ optional_header_end - optional_header_standard_fields

optional_header_standard_fields:
    dw 0x020B               ; PE32+ Executable
    dw 0                    ; Linker
    dd 4096                 ; Size of code segment
    dd 1024                 ; Size of data segment
    dd 0                    ; No .bss section
    dd 1024                 ; Entry point
    dd 1024                 ; First instruction

optional_header_windows_fields:
    dq 0x100000             ; Entry point address
    dd 1024                 ; Section alignment
    dd 1024                 ; File alignment
    dw 0                    ; Operating system requirements
    dw 0                    ; Cont.
    dw 1                    ; Major image version number
    dw 0                    ; Minor image version number
    dw 0                    ; Major subsystem version
    dw 0                    ; Minor subsystem version
    dd 0                    ; Zero
    dd 6144                 ; Image size
    dd 1024                 ; Header size
    dd 0                    ; Checksum
    dw EFI_IMAGE_SUBSYSTEM_EFI_APPLICATION ; Subsystem
    dw 0                    ; Not a DLL

    dq 0x8000               ; Stack space to reserve
    dq 0x8000               ; Stack space to commit immediately
    dq 0x8000               ; Heap space to reserve
    dq 0                    ; Local heap space to commit immediately
    dd 0                    ; Zero
    dd 0                    ; Number of data dictionary entries

optional_header_end:

section_table:
.1: ; Text section
    dq `.text`              ; Name of section
    dd 4096                 ; Virtual size
    dd 1024                 ; Virtual entry point address
    dd 4096                 ; Actual size
    dd 1024                 ; Actual entry point address
    dd 0                    ; Relocations
    dd 0                    ; Line numbers
    dw 0                    ; Relocations
    dw 0                    ; Line numbers
    dd 0x60000020           ; Contains executable code, can be executed as code, can be read

.2: ; Data section
    dq `.data`              ; Name of section
    dd 1024                 ; Virtual size
    dd 5120                 ; Virtual entry point address
    dd 1024                 ; Actual size
    dd 5120                 ; Actual entry point address
    dd 0                    ; Relocations
    dd 0                    ; Line numbers
    dw 0                    ; Relocations
    dw 0                    ; Line numbers
    dd 0xC0000040           ; Contains initialized data, can be read, can be written to

times 1024 - ($-$$) db 0    ; Alignment

section .text follows=.header

%define EFI_SUCCESS                     0

%define OFFSET_TABLE_BOOT_SERVICES      96
%define OFFSET_TABLE_ERROR_CONSOLE      80
%define OFFSET_TABLE_OUTPUT_CONSOLE     64
%define OFFSET_TABLE_RUNTIME_SERVICES   88
%define OFFSET_BOOT_EXIT_PROGRAM        216
%define OFFSET_BOOT_STALL               248
%define OFFSET_CONSOLE_OUTPUT_STRING    8

;=============================================================================;
; start                                                                       ;
;    - EFI image entry point                                                  ;
;=============================================================================;
start:
    sub rsp, 6*8+8

    mov qword [efi_handle], rcx
    mov qword [efi_system_table], rdx
    mov qword [efi_return], rsp

    ; Get essential function pointers

    add rdx, OFFSET_TABLE_BOOT_SERVICES
    mov qword rcx, [rdx]
    mov qword [boot_services], rcx
    add rcx, OFFSET_BOOT_EXIT_PROGRAM
    mov qword rdx, [rcx]
    mov qword [boot_services_exit], rdx
    mov qword rcx, [boot_services]
    add rcx, OFFSET_BOOT_STALL
    mov qword rdx, [rcx]
    mov qword [boot_services_stall], rdx

    ; Get console functions

    mov qword rdx, [efi_system_table]
    add rdx, OFFSET_TABLE_ERROR_CONSOLE
    mov qword rcx, [rdx]
    mov qword [conerr], rcx
    add rcx, OFFSET_CONSOLE_OUTPUT_STRING
    mov qword rdx, [rcx]
    mov qword [conerr_print_string], rdx

    mov qword rdx, [efi_system_table]
    add rdx, OFFSET_TABLE_OUTPUT_CONSOLE
    mov qword rcx, [rdx]
    mov qword [conout], rcx
    add rcx, OFFSET_CONSOLE_OUTPUT_STRING
    mov qword rdx, [rcx]
    mov qword [conout_print_string], rdx

    ; Runtime service functions

    mov qword rdx, [efi_system_table]
    add rdx, OFFSET_TABLE_RUNTIME_SERVICES
    mov qword rcx, [rdx]
    mov qword [runtime_services], rcx

    ; Clear registers

    xor rcx, rcx
    xor rdx, rdx
    xor r8, r8

    mov qword rcx, [conout]
    lea qword rdx, [welcome_msg]
    call [conout_print_string]

    cli
    hlt

times 4096 - ($-$$) db 0    ; Alignment

section .data follows=.text
data_start:
    efi_handle          dq 0    ; EFI handle
    efi_system_table    dq 0    ; System table
    efi_return          dq 0    ; Return

    boot_services       dq 0    ; EFI boot services
    boot_services_exit  dq 0    ; Exit function
    boot_services_stall dq 0    ; Stall boot
    conerr              dq 0    ; Console error
    conerr_print_string dq 0    ; Console error print string
    conout              dq 0    ; Console out
    conout_print_string dq 0    ; Console out print string
    runtime_services    dq 0    ; Runtime services

    welcome_msg         db __utf16__ "Ether v1.0.0 Celeritas EFI Boot", 13, 10, 0

times 1024 - ($-$$) db 0    ; Alignment
