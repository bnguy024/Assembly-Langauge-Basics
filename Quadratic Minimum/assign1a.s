// Date: Feburary 2, 2020
// File: assign1a.s 
// Author: Brandon Nguyen 30009135
//
// Description: 
// This program finds the minimim of the function of  y = 2x^4 - 145x2-44x -14 in the range -10 <= x <=10, by stepping through the range one by one in a loop and testing. 
// Using printf() to display the value x and y nad the current mimimum  

str: 	.string "When x is %ld and y is equal to %ld then minimum of the function is %ld\n"
	.balign	4			// Instructions must be word aligned
	.global main			// Make "main" visible to the OS and start the execution

main: 	stp 	x29,x30, [sp,-16]! 
	mov 	x19, -10		//Loop counter/ X value 
	mov 	x20, 0 		//Register for Y value 
	mov 	x21, 0		//Register for minimum value

test:	cmp 	x19, 10		//Compare if the loop counter is between the range of -10, 10
	b.gt	done 		// If [loop counter]>=10, exit loop and branch to "done"
	
	mov 	x20, 0		//call Y value 
	add 	x20, x20, -14	//assign y as -14
		
	mov 	x24, -44		//assign temp register -44
	mul 	x24, x24, x19      	// -44*x 
	add 	x20, x20, x24	// -44x-14
	
	mov 	x24, -145		//assign temp register -145
	mul 	x24, x24, x19 	// -145*x 
	mul 	x24, x24, x19	// (-145*x)*(-145*x) 
	add 	x20, x20, x24 	// (-145x^2)-44x-14
		
	mov 	x24, 2 
	mul 	x24, x24, x19	//2*x
	mul 	x24, x24, x19 	//2*x^2
	mul 	x24, x24, x19	//2*x^3
	mul 	x24, x24, x19	//2*x^4'
	add 	x20, x20, x24      	// (2x^4)-(145x^2)-44x-14
	 
	b	cmpv		//Go to condidional statement

cmpv:	cmp 	x20, x21 
	b.ge 	print  	

else: 	mov 	x21, x20 	

print: 	adrp	x0, str
	add	x0, x0, :lo12: str
	mov	x1, x19
	mov 	x2, x20
	mov 	x3, x21
	bl	printf
	add 	x19, x19, 1         //increment loop by 1 

	b 	test   

done:   ldp 	x29, x30, [sp], 16	// Restore FP and LR from stack
	ret			// Return to caller (OS)       
