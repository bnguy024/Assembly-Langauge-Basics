// File: assign4.asm 
// Date: March 16, 2020
// Author: Brandon Nguyen
// UCID: 30009135
// TUTORIAL: 04	
// Desciption:
// Create an ARMv8 Assembly langauge program that translate the 
// the given C code. Using subroutines, stack, variable to store all local variables. 

// Define the format strings hat will be used  
str1: .string "\nInitial pyramid values:\n" 
str2: .string "Pyramid %s\n\tCenter = (%d, %d) \n\tBase width = %d Base length = %d\n\tHeight = %d\n\tVolume = %d\n\n"
str3: .string "\tBase width = %d Base length = %d\n"
str4: .string "khafre"
str5: .string "cheops"
str6: .string "\nNew pyramid values:\n"

	//Define Macros 
define(p_base_r, x9)				// Base register for pyramid

	//Equate definition 
	FALSE = 0				// Define False
	TRUE = 1				// Define True

	// Equates for coord struct
	py_x = 0				// Offset for x
	py_y = 4				// Offset for y
	coor_size = 8				// Size of the coord struct
	// Equates for size struct			
	py_wid = 0				// Offset for width
	py_len = 4				// Offset for length
	size_size = 8				// Size of the size struct
	// Equates for pyramid struct 
	py_cen = 0				// Offset for center
	py_bas = 8				// Offset for base
 	py_hi = 16				// Offset for hieght
	py_vol = 20 				// Offset for volume 	
	py_size = 24				// size of the pyramid (coor_size + size_size + 4 + 4) 

	// Memory allocation 
	py_k = py_size 				// Make the first instance of pyramid 
	py_c = py_size				// Make a second instance of pyramid 
	alloc = -(16 + py_k + py_c) & -16 	// set the amount of memory needed 
	dealloc = -alloc 			// set the amount of memory needed to deallocate 
	
	// Equates for pyramid offset
	py_k_s = 16				// Offset of pyramid khafre in frame record 
	py_c_s = py_k_s + py_size 		// Offset of pyramid cheops in frame record 
	py_p =  16				// Offset of pyramid P 

	fp	.req	x29			// Register Equate assembler directive. Alias for x29
	lr	.req	x30			// Register Equate assembler directive. Alias for x30

	.balign 4				// Instructions must be word aligned
	.global main				// Make "main" visible to the OS and start the execution

// newPyramid function 
newPyramid:	
	stp x29, x30, [sp, alloc]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov fp, sp  				// Update frame pointer (FP) to current stack pointer (SP)
	
	add p_base_r, fp, py_p 			// Calculate pryamid stuct base address
		
	str wzr, [p_base_r, py_cen + py_x] 	// p.center.x = 0
	str wzr, [p_base_r, py_cen + py_y] 	// p.center.y = 0
	
	str w0, [p_base_r, py_bas + py_wid] 	// p.base.width = width 
	str w1, [p_base_r, py_bas + py_len] 	// p.base.length = length
	str w2, [p_base_r, py_hi] 		// p.height = height 

	ldr x10, [p_base_r, py_cen + py_x] 	// Load x coord to x10
	str x10, [x8, py_cen + py_x] 		// Store x coord on x8
	ldr x10, [p_base_r, py_cen + py_y]	// Load y coord to x10 
	str x10, [x8, py_cen + py_y]		// Store y coor to x8
	
	ldr x10, [p_base_r, py_bas + py_wid] 	// Load width on x10	
	str x10, [x8, py_bas + py_wid] 		// Store width on x8
	
	ldr x10, [p_base_r, py_bas + py_len]	// Load the length on x10 
	str x10, [x8, py_bas + py_len] 		// Store the length on x8
		
	ldr x10, [p_base_r, py_hi] 		// Load the hieght on x10
	str x10, [x8, py_hi]			// Store the hieght on x8

	mov w12, 3 				// move 3 to divide 
	
	mul w0, w0, w1  			// p.base.width * p.base.length 
	mul w2, w2, w0				// p.base.width * p.base.length * p.height
	sdiv w2, w2, w12			// (p.base.width * p.base.length * p.height)/3 
	str w2, [x8, py_vol]			// Store the result of w2 to the volume 
	
	mov w0, 0				// Return w0 to 0
	mov w1, 0				// Return w1 to 0
	mov w2, 0 				// Return w2 to 0 
	ldp x29, x30, [sp], dealloc 		// Restore FP and LR from stack
	ret 					// Return to caller (OS)
	
// printPyramid function
printPyramid: 
	stp	x29, x30, [sp, -16]! 		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP.	
	mov	fp, sp				// Update frame pointer (FP) to current stack pointer (SP)

	mov 	x28, x0				// Set the pyramid into x28 
	adrp	x0, str2			// Set high-order bits of the base string 
	add	w0, w0, :lo12:str2 		// Set base string (12 lower-order bits)
	
	ldr 	w2, [x28, py_cen + py_x] 	// Load the x coord into w2
	ldr	w3, [x28, py_cen + py_y] 	// Load the y coord into w3
	ldr 	w4, [x28, py_bas + py_wid]	// Load the width into w4
	ldr	w5, [x28, py_bas + py_len] 	// Load the length into w5
	ldr	w6, [x28, py_hi]		// Load the hieght into w6
	ldr 	w7, [x28, py_vol]		// Load the volume into w7
	bl 	printf 				// Print the inputed values 
	
	mov	w0,0 				// Return w0 to 0
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret 					// Return to caller (OS)

// equalsize function 
equalSize: 
	stp	x29, x30, [sp, -16]! 		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP.	
	mov	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)
	
	mov	x27, x0				// Set pyramid khafre into x27
	mov 	x28, x1				// Set pyramid cheops into x28	

	ldr 	w11, [x27, py_bas + py_wid]	// Load the width of the pyramid into w11
	ldr 	w12, [x28, py_bas + py_wid]	// Load the width of the pyramid into w12
	cmp 	w11, w12 			// Compare the width of both pyramids
	b.ne 	false 				// If not equal go to the false in the function
	
	ldr 	w11, [x27, py_bas + py_len]	// Load the length of the pyramid into w11
	ldr 	w12, [x28, py_bas + py_len]	// Load the length of the pyramid into w12
	cmp	w11, w12			// Compare the length of both pyramids
	b.ne 	false 				// If not equal go to false in the function

	ldr	w11, [x27, py_hi]		// Load the hieght of the pyramid into w11
	ldr	w12, [x28, py_hi]		// Load the hieght of the pyramid into w12
	cmp 	w11, w12			// Compare the hieght of both pyramids 
	b.ne	false				// If not equal go to false in the function
	
	mov 	w0,TRUE				// Set w0 = 1
	b	done_es 			// Goto Done for this function 	

false:	mov	w0, FALSE 			// Set w0 = 0

done_es: 	
	ldp 	x29, x30, [sp], 16		// Restore FP and LR from stack
	ret					// Return to caller (OS)

// expand function
expand:
	stp	x29,x30, [sp, -16]! 		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP.
	mov	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)

	mov	x28, x0 			// Use x28 as a temp register to hold pyramid structure 
	
	ldr 	w10, [x28, py_bas + py_wid] 	// Load p->base.width into w11 
	mul	w10, w1, w10			// w10 = w1 * w10 
	str 	w10, [x28, py_bas + py_wid]	// Store the result into x28 where the width is located 

 	ldr	w11, [x28, py_bas + py_len]	// Load p->base.len into w11 
	mul	w11, w1, w11			// w11 = w1 * w11 
	str	w11, [x28, py_bas + py_len] 	// Store the result of w11 into x28
		 
	ldr 	w12, [x28, py_hi]		// Load the height into w12 
	mul 	w12, w1, w12			// w12 = w1 * w12
	str	w12, [x28, py_hi]		// Store the result of w12 into x28
	
	mov	w13, 3				// Move 3 into w13 to be used for division
	mul	w10, w10, w11			// w10 = w10 * w11
	mul 	w12, w12, w10 			// w12 = w12 * w10
	sdiv	w12, w12, w13			// w12 = w12 / w13
	
	str	w12, [x28, py_vol] 		// Store the result of w12 into volume 
			
	ldp	x29, x30, [sp], 16		// Restore FP and LR from stack 		
	ret					// Return to caller (OS)

// relocate function 
relocate: 
	stp 	x29, x30, [sp, -16]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP.
	mov 	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)
		
	mov	x28, x0				// Use x28 as a temp register to hold pyramid structure 
	
	ldr	w10, [x28, py_cen + py_x] 	// Load p->center.x into w10 
	add	w10, w10, w1 			// w10 = w10 + w1
	str 	w10, [x28, py_cen + py_x] 	// Store the result in center.x 
	ldr	w10, [x28, py_cen + py_y]	// Load p->center.y into w10
	add	w10, w10, w2			// w10 = w10 + w2 
	str	w10, [x28, py_cen + py_y] 	// Store the result into center.y 
	
	ldp	x29, x30, [sp], 16		// Restore FP and LR from stack 	
	ret 					// Return to caller (OS)

main:	stp 	x29, x30, [sp, alloc]!		// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	mov 	fp, sp 				// Update frame pointer (FP) to current stack pointer (SP)
	
	add 	x8, fp, py_k_s			// Set the pyramid khafre into x8 
	// Initate the arguments in khafre	
	mov 	w0, 10 				// Int width 			
	mov 	w1, 10				// Int length
	mov 	w2, 9 				// Int height 
	bl	newPyramid 

	add x8, fp, py_c_s			// Set the pyramid cheops into x8 	
	// Initate the arguments in cheops 
	mov w0, 15				// Int width 
	mov w1, 15 				// Int length
	mov W2, 18				// Int height 
	bl 	newPyramid
		
	// Note: at this point I stopped using x8 because I kept getting segmentation faults 
	
	adrp	x0, str1 			// Set high-order bits of the base string 
	add	w0, w0, :lo12:str1 		// Set base string (12 lower-order bits)
	bl	printf 				// Print the initial value
	
	add	x0, fp, py_k_s			// Set the pyramid khafree to x0
	adrp	x1, str4			// Set the string "khafre" into x1
	add	w1, w1, :lo12:str4 		// Set base string (12 lower-order bits)
	bl 	printPyramid			// Goto printPyramid
	
	add	x0, fp, py_c_s			// Set the pyramid cheops to x0 
	adrp	x1, str5 			// Set string "cheops" into x1 
	add	w1, w1, :lo12:str5		// Set the lower 12 bits 
	bl	printPyramid			// Goto printPyramid 
	
	add	x0, fp, py_k_s 			// Set pyramid khafre into x0 to be passed as an argument
	add	x1, fp, py_c_s			// Set pyramid cheops into x1 to be passed as an argument
	bl 	equalSize 			// Goto equalSize function
	
	cmp 	w0, TRUE 			// Compare if w0 = 1 
	b.eq	finalprint 			// If the value at w0 = 1 goto finalprint function 
	
 	add	x0, fp, py_c_s			// Set the pyramid cheops into x0 to be passed as an argument
	mov 	w1, 9				// Set the argument for expand function
	bl	expand 				// Goto expand function
	
	add	x0, fp, py_c_s			// Set the pyramid cheops into x0 to be passed as an argument
	mov	w1, 27				// Set the arugment for relocate function
	mov	w2, -10 			// Set the arugment for relocate function 
	bl	relocate 			// Goto relocate function
	
	add	x0, fp, py_k_s			// Set the pyramid khafree into x0 to be passed as an argument	
	mov	w1, -23				// Set the argument for relocate function
	mov	w2, 17 				// Set the argument for relocate function 
	bl	relocate			// Goto relocate function 
	
finalprint: 
	adrp	x0, str6 			// Set high-order bits of the new value string 
	add	w0, w0, :lo12:str6 		// Set String argument (12 lower-order bits)
	bl 	printf				// Print the string for new values  

	add 	x0, fp, py_k_s			// Set the pyramid khafre into  x0 
	adrp	x1, str4			// Set the string "khafre" into x1 
	add	w1, w1, :lo12:str4 		// Set the lower 12 bits into khafre
 	bl 	printPyramid			// Print the new contents of khafre
	
	add	x0, fp, py_c_s			// Set the pyramid cheops into x0 
	adrp	x1, str5 			// Set the string "cheops" into x1 
	add	w1, w1, :lo12:str5		// Set the lower 12 bits into cheops
	bl 	printPyramid 			// Print the new contents of cheops

done: 	mov 	w0, 0 				// Return 0 to OS 		
	ldp x29, x30, [sp], dealloc 		// Restore FP and LR from stack 		
	ret 					// Return to caller (OS)


