section .text
	global sort

;; IMPLEMENTATION:
;	The function finds each step the smallest element that
;	is unvisited. After finding it, we link it with the
; 	previously found one by placing the adress to the node
; 	in next field(previous_node.next = &next_node).

;; struct node* find_next(int n, struct node* first_node,
; 		struct node* previous_node);
;	This function seeks the next node to be put in the
;	sorted list and links it with its predecessor.
; @params:
;	n -> number of nodes in the array
;	first_node -> the first node in the unsorted array
;	previous_node -> the last node that has been found
;	in the sorted order
; @returns:
;	the newly linked node from the ordered sequence
find_next:
	enter 0, 0

	;;@variables
	;counter
	mov ecx, [ebp + 8]
	;parser pointer
	mov ebx, [ebp + 12]
	;next_node -> to be returned
	xor eax, eax

seek:
	;;is the node unvisited?
	cmp [ebx + 4], dword 0
	jne next_node
	;in case the node is same as the previous node
	cmp ebx, [ebp + 16]
	je next_node

	;;is this node's value the smallest found so far?
	;in case we have no previous node found
	cmp eax, 0
	je update_node
	;in case we have a previous node found
	mov esi, [eax]
	cmp esi, [ebx]
	jle next_node
update_node:
	mov eax, ebx
next_node:
	add ebx, 8
	loop seek

	;;creating the link
	mov ebx, [ebp + 16]
	mov [ebx + 4], eax

	leave
	ret

; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter 0, 0

	;;@variables
	;smallest node -> returned value
	mov eax, [ebp + 12]
	;parser pointer
	mov ebx, eax
	;counter
	mov ecx, [ebp + 8]

find_first_minimum:
	mov esi, [eax]
	cmp [ebx], esi
	jge next_it
	mov eax, ebx
next_it:
	add ebx, 8
	loop find_first_minimum

	;;save the smallest node
	push eax

	;;@variable
	;counter
	mov ecx, [ebp + 8]

place_one_link:
	;;save the counter
	push ecx
	
	;;find next smallest node
	;eax always stores the last smallest node found
	push eax
	push dword [ebp + 12]
	push dword [ebp + 8]
	call find_next
	add esp, 12
	
	;;move to the next link
	pop ecx
	loop place_one_link

	;;retrieve back the first node
	pop eax

	leave
	ret