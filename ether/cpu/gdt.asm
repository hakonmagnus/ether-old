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

%define PRESENT         1 << 7
%define CPL_3           3 << 6
%define NOT_SYS         1 << 4
%define EXEC            1 << 3
%define DC              1 << 2
%define RW              1 << 1
%define ACCESSED        1 << 0

%define GRAN_4K         1 << 7
%define SZ_32           1 << 6
%define LONG_MODE       1 << 5

section .data
global gdt_start
global gdt_end

gdt_start:
.null:
    dq 0

.code:
    dd 0xFFFF
    db 0
    db PRESENT | NOT_SYS | EXEC | RW
    db GRAN_4K | LONG_MODE | 0xF
    db 0

.data:
    dd 0xFFFF
    db 0
    db PRESENT | NOT_SYS | RW
    db GRAN_4K | SZ_32 | 0xF
    db 0

.user_code:
    dd 0xFFFF
    db 0
    db PRESENT | CPL_3 | NOT_SYS | EXEC | RW
    db GRAN_4K | LONG_MODE | 0xF
    db 0

.user_data:
    dd 0xFFFF
    db 0
    db PRESENT | CPL_3 | NOT_SYS | RW
    db GRAN_4K | SZ_32 | 0xF
    db 0

gdt_end:
    dw $ - gdt_start - 1
    dq gdt_start