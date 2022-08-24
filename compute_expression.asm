section .text

global expression
global term
global factor

;; IMPLEMENTATION:
;       The whole input string and any substring contained
;       by parantheses is seen as an expression. Anything
;       else is either a term or a factor.
;  @subfunctions
;  EXPRESSION:
;       The algorithm looks for terms to add or substract.
;       Terms are delimited by - or + operations. Upon
;       entering the function, it checks each character
;       to see what to do next. If it's a + or -, this
;       value is saved so that to know what to do with
;       the next term found in the iteration(add to the
;       rest of it or substract from it). If it's an ),
;       or \0, the function ends and if it's anything
;       else, it calls term function to deal with it.
;  TERM:
;       The algorithm is similar, only it looks for
;       factors to multiply or divide by. (*,/) is
;       similar with (+,-) from expression and
;       (\0,')',+,-) are markers for the end of a term.
;       Anything else is to be dealt with by the factor
;       function, which is called in such cases.
;  FACTOR:
;       This function knows to call the expression function
;       when it spots a (, and to calculate a number from
;       a substring of digits. Any other character is a
;       marker for end of a factor.
;     

; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
factor:
        push    ebp
        mov     ebp, esp
        
        ;;@variables
        ;returned number
        xor eax, eax
        ;full expression
        mov esi , [ebp + 8]
        ;index in the expression
        mov ecx, [ebp + 12]
        mov ecx, [ecx]

digits_loop:
        ;;@variable
        ;current char
        xor ebx, ebx
        mov bl, [esi + ecx]
        
        ;;checking whether we reached a digit
        cmp bl, '0'
        jl not_a_digit
        cmp bl, '9'
        jg not_a_digit

        ;;updating the returned number
        sub bl, 48
        mov edx, 10
        mul edx
        add eax, ebx

        ;;moving to next char
        inc ecx
        jmp digits_loop
not_a_digit:
        ;;checking whether we start a new expression
        cmp bl, '('
        jne get_out_factor

        ;;moving to next position
        inc ecx

        ;;saving the value at the remote address
        mov eax, [ebp + 12]
        mov [eax], ecx

        ;; putting in eax the result of the expression that starts at this point
        push eax
        push esi
        call expression

get_out_factor:
        ;;saving the value of the index at the remote address
        mov ebx, [ebp + 12]
        mov [ebx], ecx

        leave
        ret

; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
term:
        push    ebp
        mov     ebp, esp
        
        ;;@variables
        ;value returned -> product of factors/expressions
        mov eax, 1
        ;marker for * or /
        mov dx, '*'
        ;full expression
        mov esi , [ebp + 8]
        ;index
        mov ecx, [ebp + 12]
        mov ecx, [ecx]

factors_loop:
        ;;@variable
        ;current char
        xor ebx, ebx
        mov bl, [esi + ecx]

        ;;analyse the char and choose what to do
        cmp bl, '*'
        je term_specific_operation
        cmp bl, '/'
        je term_specific_operation
        cmp bl, '+'
        je get_out_term
        cmp bl, '-'
        je get_out_term
        cmp bl, ')'
        je get_out_term
        cmp bl, 0
        je get_out_term

        ;;multiply or divide?
        sub bl, 48
        cmp dl, '*'
        je multiply
        jmp divide
term_specific_operation:
        ;;save the operation
        mov dx, bx

        inc ecx
        jmp factors_loop
multiply:
        ;;preserve old values
        push eax
        push edx

        ;;saving the value at the remote address
        mov eax, [ebp + 12]
        mov [eax], ecx

        ;;getting the result from factor
        push eax
        push esi
        call factor
        add esp, 8
        
        ;;making space in eax
        mov ebx, eax

        ;;restoring values
        pop edx
        pop eax
        mov esi , [ebp + 8]
        mov ecx, [ebp + 12]
        mov ecx, [ecx]
        
        ;;update eax
        imul ebx
        jmp factors_loop
divide:
        ;;preserve old values
        push eax
        push edx

        ;;saving the value at the remote address
        mov eax, [ebp + 12]
        mov [eax], ecx

        ;;getting the result from factor
        push eax
        push esi
        call factor
        add esp, 8
        
        ;;making space in eax
        mov ebx, eax

        ;;restoring values
        pop edx
        pop eax
        mov esi , [ebp + 8]
        mov ecx, [ebp + 12]
        mov ecx, [ecx]

        ;;update eax
        push edx
        cdq
        idiv ebx
        pop edx
        jmp factors_loop

get_out_term:
        ;;saving the value at the remote address
        mov ebx, [ebp + 12]
        mov [ebx], ecx

        leave
        ret

; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
expression:
        push    ebp
        mov     ebp, esp

        ;;@variables
        ;returned value -> sum of terms
        xor eax, eax
        ;marker for + or -
        mov dx, '+'
        ;full expression
        mov esi , [ebp + 8]
        ;index
        mov ecx, [ebp + 12]
        mov ecx, [ecx]

terms_loop:
        ;;current char
        xor ebx, ebx
        mov bl, [esi + ecx]

        ;;analyse the char and choose where to go
        cmp bl, '+'
        je expr_specific_operation
        cmp bl, '-'
        je expr_specific_operation
        cmp bl, ')'
        je get_out_expr
        cmp bl, 0
        je get_out_expr

        ;;add or substract?
        sub bl, 48
        cmp dl, '+'
        je addition
        jmp substract
expr_specific_operation:
        ;;save the operation
        mov dx, bx

        inc ecx
        jmp terms_loop
addition:
        ;;preserve old values
        push eax
        push edx

        ;;saving the value at the remote address
        mov eax, [ebp + 12]
        mov [eax], ecx

        ;;getting the result from term
        push eax
        push esi
        call term
        add esp, 8
        
        ;;making space in eax
        mov ebx, eax

        ;;restoring values
        pop edx
        pop eax
        mov esi , [ebp + 8]
        mov ecx, [ebp + 12]
        mov ecx, [ecx]
        
        ;;update eax
        add eax, ebx
        jmp terms_loop
substract:
        ;;preserve old values
        push eax
        push edx

        ;;saving the value at the remote address
        mov eax, [ebp + 12]
        mov [eax], ecx

        ;;getting the result from term
        push eax
        push esi
        call term
        add esp, 8
        
        ;;making space in eax
        mov ebx, eax

        ;;restoring values
        pop edx
        pop eax
        mov esi , [ebp + 8]
        mov ecx, [ebp + 12]
        mov ecx, [ecx]

        ;;update eax
        sub eax, ebx
        jmp terms_loop

get_out_expr:
        ;;moving to the next position
        inc ecx

        ;;saving the value at the remote address
        mov ebx, [ebp + 12]
        mov [ebx], ecx
        leave
        ret
