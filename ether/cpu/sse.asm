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

bits 64

section .data
global sse2_supported
global sse3_supported
global ssse3_supported
global sse41_supported
global sse42_supported
global sse4a_supported
global xop_supported
global fma4_supported
global cvt16_supported
global avx_supported
global xsave_supported
global avx2_supported

sse2_supported db 0
sse3_supported db 0
ssse3_supported db 0
sse41_supported db 0
sse42_supported db 0
sse4a_supported db 0
xop_supported db 0
fma4_supported db 0
cvt16_supported db 0
avx_supported db 0
xsave_supported db 0
avx2_supported db 0

section .text
global sse_init

;=============================================================================;
; sse_init                                                                    ;
;    - Check SSE capabilities and enable                                      ;
;=============================================================================;
sse_init:
    mov rax, 1
    cpuid
    
    test rdx, 1 << 26
    jz .no_sse2
    
    mov byte [sse2_supported], 1

.no_sse2:
    test rcx, 1 << 0
    jz .no_sse3
    
    mov byte [sse3_supported], 1

.no_sse3:
    test rcx, 1 << 9
    jz .no_ssse3
    
    mov byte [ssse3_supported], 1

.no_ssse3:
    test rcx, 1 << 19
    jz .no_sse41
    
    mov byte [sse41_supported], 1

.no_sse41:
    test rcx, 1 << 20
    jz .no_sse42
    
    mov byte [sse42_supported], 1

.no_sse42:
    test rcx, 1 << 6
    jz .no_sse4a
    
    mov byte [sse4a_supported], 1

.no_sse4a:
    test rcx, 1 << 11
    jz .no_xop
    
    mov byte [xop_supported], 1

.no_xop:
    test rcx, 1 << 16
    jz .no_fma4
    
    mov byte [fma4_supported], 1

.no_fma4:
    test rcx, 1 << 29
    jz .no_cvt16
    
    mov byte [cvt16_supported], 1

.no_cvt16:
    test rcx, 1 << 26
    jz .no_xsave
    
    mov byte [xsave_supported], 1

.no_xsave:
    test rcx, 1 << 28
    jz .no_avx
    
    mov byte [avx_supported], 1

.no_avx:
    mov rax, 7
    xor rcx, rcx
    cpuid
    
    test rdx, 1 << 26
    jz .no_avx2
    
    mov byte [avx2_supported], 1

.no_avx2:
    mov eax, 1
    cpuid
    test edx, 1 << 25
    jz .done
    
    ; Enable SSE
    mov rax, cr0
    and ax, 0xFFFB
    or ax, 2
    mov cr0, rax
    mov rax, cr4
    or ax, 3 << 9
    mov cr4, rax
    
    cmp byte [avx_supported], 0
    je .done
    
    ; Enable AVX
    xor rcx, rcx
    xgetbv
    or rax, 7
    xsetbv

.done:
    ret