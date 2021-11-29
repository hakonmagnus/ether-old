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
; int_to_string                                                               ;
;    - Convert an integer to a string value                                   ;
;    @param EAX = Integer value                                               ;
;    @return EAX = ASCII string                                               ;
;=============================================================================;
int_to_string:
    pusha

    xor ecx, ecx
    mov ebx, 10
    mov edi, .t

.push:
    xor edx, edx
    div ebx
    inc ecx
    push edx
    test eax, eax
    jnz .push

.pop:
    pop edx
    add dl, '0'
    mov byte [edi], dl
    inc edi
    dec ecx
    jnz .pop

    mov byte [edi], 0

    popa
    mov eax, .t
    ret

    .t times 11 db 0

int_to_hex:
    pusha

    xor ecx, ecx
    mov ebx, 16
    mov edi, .t

.push:
    xor edx, edx
    div ebx
    inc ecx
    push edx
    test eax, eax
    jnz .push

.pop:
    pop edx
    cmp dl, 9
    ja .alpha

    add dl, '0'
    jmp .cont

.alpha:
    sub dl, 10
    add dl, 'A'

.cont:
    mov byte [edi], dl
    inc edi
    dec ecx
    jnz .pop

    mov byte [edi], 0

    popa
    mov eax, .t
    ret

    .t times 9 db 0
