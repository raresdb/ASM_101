;; constants
CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFSSET_BITS


section .text
    global load
    extern printf

;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE], char* address, int to_replace);
load:
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)

;;compute the tag
tag:
    mov esi, [edx]
    shr esi, OFFSET_BITS

    ;;temporarily used as counter
    mov edi, CACHE_LINES

tag_search:
    dec edi
    cmp [ebx + 4 * edi], esi
    je found
    cmp edi, 0
    jne tag_search

;;if the tag is not found in the list
not_found:

    ;;this register will keep the line where we read from the cache
    push esi

    ;;retreive the old value
    mov edi, [ebp + 24]
    
    
    mov esi, edi

    ;;start adress of the line we copy(addr & 2 ^ 32 - 2 ^ 3)
    and edx, 4294967288
    
    ;;store data in the cache
    mov ebx, [edx]
    mov [ecx + CACHE_LINE_SIZE * edi], ebx
    mov ebx, [edx + 4]
    add ecx, 4
    mov [ecx + CACHE_LINE_SIZE * edi], dword ebx
    mov ebx, [ebp + 12]

    ;;store the new tag in the tag list
    pop ecx
    mov [ebx + edi * 4], ecx

    ;;restore old values
    mov ecx, [ebp + 16]
    mov edx, [ebp + 20]

    jmp register

;;if the tag is found in the list
found:
    ;;same purpose as above at the not_found tag
    mov esi, edi

;;write in the register
register:

    ;;computing the offset in the line
    mov edi, edx
    and edi, 4294967288
    add ecx, edx
    sub ecx, edi

    ;;moving from cache to the register
    mov ebx, [ecx + esi * CACHE_LINE_SIZE]
    mov [eax], ebx

    popa
    leave
    ret


