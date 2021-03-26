// Date: Feburary 3, 2020
// File: assign1b.asm 
// Author: Brandon Nguyen 30009135
//
// Description: 
// Create an otimized version of assign1a using macros, madd and an optimized pre-looped test

// Define macros






 



str:	.string "When x is %ld and y is equal to %ld then minimum of the function is %ld\n"
	.balign	4			// Instructions must be word aligned
	.global main			// Make "main" visible to the OS and start the execution

main: 	stp 	x29, x30, [sp,-16]!	// Save FP and LR to Stack  
	mov	x29, sp			// Update FP to the current SP
	
	mov 	x19, -10
	mov 	x20, 0 
	mov	x21, 0
	
	b	test 

loop:	mov  	x20, -14
	
	mov 	x24, -44
	madd 	x20,x24,x19, x20	//-44 * x + -14	
	
	mov	x24, -145 
	mul 	x24, x24, x19 
	madd	x20, x24, x19, x20
	
	mov 	x24, 2    
	mul 	x24, x24, x19 
	mul 	x24, x24, x19 
	mul 	x24, x24, x19 
	madd 	x20, x24, x19, x20
	
	b 	cmpv 

test: 	cmp 	x19, 10
	b.le 	loop			// If (x value) >= 10, exit loop and goto done

done:   ldp 	x29, x30, [sp], 16	// Restore FP and LR from stack
	ret				// Return to caller (OS)        
	
cmpv:	cmp 	x20, x21
	b.ge  	print

else: 	mov	x21, x20  

print: 	adrp	x0, str 
	add	x0, x0, :lo12:str
	mov	x1, x19
	mov	x2, x20
	mov	x3, x21	
	bl	printf 
	add   	x19, x19, 1 	
	b	test 
		   

