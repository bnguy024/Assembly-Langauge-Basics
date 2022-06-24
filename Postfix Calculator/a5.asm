// File: a5.asm 
// Date: March 16, 2020
// Author: Brandon Nguyen
// UCID: 30009135
// TUTORIAL: 04	
// Desciption:
// Translate the given c code into ARMv8 assembly langauge

// Equate Definiton 
	MAXVAL = 100 				// Define the MAXVAL
	BUFSIZE = 100 				// Define BUFSIZE 
	
	fp	.req	x29			// Register Equate assembler directive. Alias for x29
	lr	.req	x30			// Register Equate assembler directive. Alias for x30

// Eqautes for global variables 
	.data 
a_sp:	.word 	0				// initialize global var a_sp 
bufp: 	.word 	0				// initialize global var bufp 
val: 	.skip	4*MAXVAL			// Initialize global var val 
buf: 	.skip 	1*BUFSIZE  			// Initialize global var buf

// Make equates global 

	.global a_sp
	.global val 
	.global bufp 
	.global buf 	

// Make function global 	
	.global push 
	.global pop 
	.global clear 
	.global getch
	.global ungetch 
				 
// Define the format strings that will be used  
	.text 
str1:	.string "error: stack full\n"			// stack is full print statement (string literal) 
str2:   .string "error: stack empty\n"			// stack is empty print statement
str3: 	.string "ungetch: too many characters\n"	// ungetch print statement 
	
	.balign 4					// Instructions must be word aligned

// Function: push(int f) 

push:	stp	x29, x30, [sp, -16]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov	fp, sp  			// Update frame pointer (FP) to current stack pointer (SP)		
	
	adrp	x9, a_sp 			// Use adrp to get the base address of val
	add	x9, x9, :lo12:a_sp		// add the lower 12 bits of val address
	ldr	w10, [x9]			// using x10 as a pointer, load the value of a_sp 
	
	cmp	w10, MAXVAL			//  If a_sp < MAXVAL 
	b.ge  	push_next			//  If greater than than go to push_next 
	
	adrp	x11, val			// Use adrp to get the base address of val 
	add 	x11, x11, :lo12:val		// add the lower 12 bits of val address 
	
	str 	w0, [x11, w10, SXTW 2] 		// val[a_sp] = f 
	add 	w10, w10, 1 			// Increment a_sp by 1 
	str 	w10, [x9]			// Store the a_sp back to it's address 

	b	push_exit			 
	
push_next: 
	adrp	x0, str1 			// Use adrp to get the base address of the first string
	add 	x0, x0, :lo12:str1   		// add the lower 12 bits of the string
	bl	printf	
	bl	clear 				// Go to clear function 
	mov	w0, 0				// Return 0 

push_exit:
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret 					// Return to caller (OS)

// Function: pop()
pop: 	stp	x29, x30, [sp, -16]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov 	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)

	adrp 	x10, a_sp			// Use adrp to get the base address of a_sp	
	add 	x10, x10, :lo12:a_sp 		// Add lower 12 bits of a_sp address
	ldr 	w9, [x10]			// Load into w9 a_sp 

	cmp 	w9, 0				// compare if a_sp > 0 
	b.gt	pop_next

	adrp	x0, str2 			// Use adrp to get the base address of the second string
	add 	x0, x0, :lo12:str2   		// add the lower 12 bits of the string
	bl	printf	
	bl	clear 				// Go to clear function 
	mov 	w0, 0				// Return 0 
	
	b 	pop_exit 			// go to pop_exit to exit the function 	

pop_next:
	sub 	w9, w9, 1 			// decrement a_sp by 1 
	str	w9,[x10] 			// Store the value after decrementing 
	adrp 	x11, val 			// Use adrp to get the base address of val 	
	add 	x11, x11, :lo12:val 		// Add lower 12 bits of val address 
	ldr 	w0, [x11, w9, SXTW 2]		// Store the result after decrementing into the array
	
pop_exit: 
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret 					// Return to caller (OS)

// Function: clear() 
clear:	stp	x29, x30, [sp, -16]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov 	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)


	adrp 	x10, a_sp 			// Use adrp to get the base address of a_sp 
	add 	x10, x10, :lo12:a_sp 		// Add Lower 12 bits of a_sp address 
	ldr	w9, [x10] 			// Using x10 as a pointer, load the value of a_sp 
	
	mov 	w9, 0				// Set a_sp to 0 
	str 	w9, [x10]  			// Store the a_sp back to its address 				
	
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret 					// Return to caller (OS)
	
// Function: getch() 
getch: 	stp	x29, x30, [sp, -16]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov 	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)
		
	adrp	x10, bufp 			// Use adrp to get the base address of bufp
	add	x10, x10, :lo12:bufp 		// Add lower 12 bits of bufp address
	ldr 	w9, [x10] 			// Using x10 as a pointer, load the value of bufp 	
	
	cmp 	w9, BUFSIZE			// if bufp > BUFSIZE
	b.le	getch_false
	
	adrp	x11, buf			// Use adrp to get the base address of buf 	
	add 	x11, x11, :lo12:buf		// Add lower 12  bits 
	
	sub	w9, w9, 1			// Decrement bufp by 1 
	str 	w9, [x10] 			// Store the value of bufp after decrementing 
	ldr 	w0,[x11, w9, SXTW 2] 		// load into w0 buf[--bufp] 
	
	b	getch_exit 			// Goto the end of the function 
getch_false: 
	bl	getchar				// Branchlink getcha() from c library 
	
getch_exit: 	
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret 					// Return to caller (OS)

// Function: ungetch() 
ungetch:	
	stp	x29, x30, [sp, -16]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov 	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)
	

	adrp	x11, bufp 			// Use adrp to get the base address of bufp
	add	x11, x11, :lo12:bufp 		// Add lower 12 bits of bufp address
	ldr 	w10, [x11] 			// Using x11 as a pointer, load the value of bufp 

	cmp	w10, BUFSIZE			// if bufp > BUFSIZE 	
	b.gt	ungetch_next 	  		// Go to next 
	
	adrp 	x12, buf 			// Use adrp to get the base address of buf 	 
	add 	x12, x12, :lo12:buf 		// Add the lower 12 bits of buf address 	
	
	str 	w0, [x12, w10, SXTW 2] 		// buf[bufp] = c
	add	w10, w10 , 1			// Increment bufp by 1 
	str 	w10, [x11]			// Store the a_sp back to it's address 
	
	b	ungetch_exit 		
ungetch_next: 	  		
	adrp	x0, str3 			// Use adrp to get the base address of the second string
	add 	x0, x0, :lo12:str3   		// add the lower 12 bits of the string
	bl	printf	

ungetch_exit: 	
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret 					// Return to caller (OS)

