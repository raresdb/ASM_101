section .text
	global cmmmc

;; IMPLEMENTATION:
;	The function picks all natural numbers > 1 and starts
;	dividing both parameters as many times as possible
;	by each number(old values of parameters aren't
;	restored when going to another number). Each time
;	the greater factor(number ^ no div) obtained from
;	the 2 parameters is stored. After exhausting the
;	parameters of possible divisions, the function
;	returns the product of these factors.
;	

;; int cmmmc(int a, int b)
;
;; calculate least common multiple for 2 numbers, a and b
cmmmc:

	;;getting the old esp out of the way, in order to access
	;the parameters from the stack
	pop edx

	;;@variables
	;remainder of a and b
	pop esi
	pop edi
	;number to divide by
	push 2
	pop ecx

	;;restoring the stack
	sub esp, 12

	;;0 will be used as the stop point when extracting
	;the factors
	push 0

factors_loop:
	;;@variable
	;factor
	push 1
	pop ebx
div_a:
	;;trying to divide a
	xor edx, edx
	push esi
	pop eax
	div ecx

	;;checking if the division resulted in an integer
	cmp edx, 0
	jne preps_for_div_b

	;;update a
	push eax
	pop esi

	;;update the factor obtained from a
	push ebx
	pop eax
	mul ecx
	push eax
	pop ebx

	jmp div_a
preps_for_div_b:
	;;saving the factor obtained from a
	push ebx

	;;@variable
	;factor
	push 1
	pop ebx	
div_b:
	;;trying to divide b
	xor edx, edx
	push edi
	pop eax
	div ecx

	;;checking if the division resulted in an integer
	cmp edx, 0
	jne upload

	;;update b
	push eax
	pop edi

	;;update the factor obtained from b
	push ebx
	pop eax
	mul ecx
	push eax
	pop ebx

	jmp div_b
upload:
	;;getting back the factor obtained from a
	pop edx

	;;uploading the greater one
	cmp edx, ebx
	jg push_factor_a
	push ebx
	jmp next
push_factor_a:
	push edx
next:
	inc ecx

	;;next factor or exit the loop?
	cmp esi, 1
	jne factors_loop
	cmp edi, 1
	jne factors_loop

	;;@variables
	;factor
	pop ecx
	;returned value(product)
	push 1
	pop eax

extract_factors:
	mul ecx
	pop ecx
	cmp ecx, 0
	jne extract_factors

	ret
