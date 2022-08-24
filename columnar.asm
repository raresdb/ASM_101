section .data
    extern len_cheie, len_haystack

section .text
    global columnar_transposition

;; void columnar_transposition(int key[], char *haystack, char *ciphertext);
columnar_transposition:
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext

    ;;calculating number of lines in the matrix
    mov eax, [len_haystack]
    xor edx, edx
    div dword [len_cheie]

    cmp edx, 0
    jne apply_ceil
    jmp after_ceil

;;if the remaining of the div is not 0, then the ceil will return quotient + 1
apply_ceil:
    inc eax

after_ceil:

    ;;storing the number of lines in the stack
    push eax

    mov ecx, [len_cheie]

colon_loop:
    dec ecx

    ;;lines counter
    mov edx, [ebp - 36]

line_loop:
    dec edx

    ;;preserve the current line
    push edx

    ;;start computing the offset in the string -> getting on the right line
    mov eax, edx
    mul dword [len_cheie]

    ;;retrieving the line
    pop edx

    ;;finish computing the offset in the string -> getting on the right column
    add eax, [edi + 4 * ecx]

    ;;if out of bounds, we move on to next line
    cmp eax, [len_haystack]
    jge line_loop

    ;;saving the value in the stack
    mov al, [esi + eax]
    push eax

    cmp edx, 0
    jne line_loop

    cmp ecx, 0
    jne colon_loop

    ;;counter for next loop
    xor ecx, ecx

;;getting the values back from the stack into the output string
out_loop:
    pop eax
    mov [ebx + ecx], al
    inc ecx
    cmp ecx, [len_haystack]
    jne out_loop

    ;;empty the stack
    pop eax

    popa
    leave
    ret