// Date: Feburary 3, 2020
// File: assign1b.asm 
// Author: Brandon Nguyen 30009135
//
// Description: 
// Create an otimized version of assign1a using macros, madd and an optimized pre-looped test

// Define macros
define(x_val, x19)
define(y_val, x20)
define(min_val, x21)
define(temp1,x24)
define(arg1, x1)
define(arg2, x2)
define(arg3, x3) 
define(base_str, x0)


str:	.string "When x is %ld and y is equal to %ld then minimum of the function is %ld\n"
	.balign	4			// Instructions must be word aligned
	.global main			// Make "main" visible to the OS and start the execution

main: 	stp 	x29, x30, [sp,-16]!	// Save FP and LR to Stack  
	mov	x29, sp			// Update FP to the current SP
	
	mov 	x_val, -10
	mov 	y_val, 0 
	mov	min_val, 0
	
	b	test 

loop:	mov  	y_val, -14
	
	mov 	temp1, -44
	madd 	y_val,temp1,x_val, y_val	//-44 * x + -14	
	
	mov	temp1, -145 
	mul 	temp1, temp1, x_val 
	madd	y_val, temp1, x_val, y_val
	
	mov 	temp1, 2    
	mul 	temp1, temp1, x_val 
	mul 	temp1, temp1, x_val 
	mul 	temp1, temp1, x_val 
	madd 	y_val, temp1, x_val, y_val
	
	b 	cmpv 

test: 	cmp 	x_val, 10
	b.le 	loop			// If (x value) >= 10, exit loop and goto done

done:   ldp 	x29, x30, [sp], 16	// Restore FP and LR from stack
	ret				// Return to caller (OS)        
	
cmpv:	cmp 	y_val, min_val
	b.ge  	print

else: 	mov	min_val, y_val  

print: 	adrp	base_str, str 
	add	base_str, base_str, :lo12:str
	mov	arg1, x_val
	mov	arg2, y_val
	mov	arg3, min_val	
	bl	printf 
	add   	x_val, x_val, 1 	
	b	test 
		   

