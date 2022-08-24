section .text
	global par

;; IMPLEMENTATION:
;	The function parses the string and holds into account
;	the number of unclosed parantheses(previosly opened,
;	but not closed). If this number drops under 0, the
;	function stops and returns false. At the end, the
;	number of unclosed parantheses has to be 0 to return
;	true.

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
par:
	;;getting the instruction pointer out of the way
	pop edx

	;;@variables
	;counter
	pop ecx
	;pointer to the current char
	pop esi
	;;number of unclosed parantheses
	push 0
	pop ebx

	;;restoring the stack
	sub esp, 12

count_parantheses:
	cmp [esi], byte '('
	jne decrease
	inc ebx
	jmp next
decrease:
	dec ebx
next:
	;;going to the next char
	add esi, 1

	;;making sure there are not more closed parantheses than opened
	cmp ebx, 0
	jl false
	loop count_parantheses

	;;checking the final result
	cmp ebx, 0
	jne false

true:
	push 1
	pop eax
	jmp end

false:
	xor eax, eax

end:
	ret
