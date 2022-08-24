global get_words
global compare_func
global sort
extern strcmp
extern strlen
extern qsort
extern strtok

section .data

delimiters db ` .,\n`, 0 

section .text

;;  int comp(char** str1, char** str2)
;   function that compares 2 strings
compare_func:
    enter 0, 0

    ;;preserve de callee-saved registers
    push esi
    push edi
    push ebx

    ;;getting the lengths
    mov esi, [ebp + 12]
    push dword [esi]
    call strlen
    mov ebx, eax
    mov esi, [ebp + 8]
    push dword [esi]
    call strlen

    ;;checking the lengths
    cmp eax, ebx
    jg first_is_bigger
    jl second_is_bigger

    ;;returning strcmp(a, b)
    ;the parameters are already on the stack
    call strcmp
    
    jmp get_out

first_is_bigger:
    mov eax, 1
    jmp get_out

second_is_bigger:
    mov eax, -1

get_out:
    ;;restore the callee-saved registers
    add esp, 8
    pop ebx
    pop edi
    pop esi

    leave
    ret

;; sort(char **words, int number_of_words, int size)
;  will use qsort to sort after length, followed by a lexicographical sort
sort:
    enter 0, 0

    push compare_func
    push dword [ebp + 16]
    push dword [ebp + 12]
    push dword [ebp + 8]
    call qsort

    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separates the string in word
get_words:
    enter 0, 0

    ;;obtain first token
    push delimiters
    push dword [ebp + 8]
    call strtok
    add esp, 8

    ;;@variables
    ;current position in the output vector
    mov esi, [ebp + 12]
    mov [esi], eax
    add esi, 4
    ;;counter
    mov ecx, [ebp + 16]
    dec ecx

parse_words:
    ;;save caller-saved register
    push ecx

    ;;obtaining one token
    push delimiters
    push 0
    call strtok
    add esp, 8

    ;;restoring the counter
    pop ecx

    ;;storing the string in the vector
    mov [esi], eax

    add esi, 4
    loop parse_words

    leave
    ret
