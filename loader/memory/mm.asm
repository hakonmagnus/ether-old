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

mm_next dd loader_end

;=============================================================================;
; mm_alloc                                                                    ;
;    - Allocate memory                                                        ;
;    @param EAX = Size of memory requested                                    ;
;    @return EAX = Memory pointer                                             ;
;=============================================================================;
mm_alloc:
    push ebx
    
    cmp eax, 0
    je .done
    
    mov ebx, eax
    mov dword eax, [mm_next]
    add dword [mm_next], ebx
    
.done:
    pop ebx
    ret