// File: assign4.asm 
// Date: March 16, 2020
// Author: Brandon Nguyen	
// Desciption:
// Create an ARMv8 Assembly langauge program that translate the 
// the given C code. Using subroutines, stack, variable to store all local variables. 


str1: .string "\nInitial pyramid values:\n" 
str2: .string "\tCenter = (%d, %d) \n\tBase width = %d Base length = %d\n\tHeight = %d\n\tVolume = %d\n\n"
str3: .string "\tBase width = %d Base length = %d\n"
str4: .string "khafre\n"
str5: .string "cheops\n"
str6: .string "\nNew pyramid values:\n"
str7: .string "Pyramid %s\n"

	//Define Macros 

define(p_base_r, x9)				// Make base address for p 



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

	.balign 4
	.global main


newPyramid:	
	stp x29, x30, [sp, alloc]!		
	mov fp, sp  
	
	add p_base_r, fp, py_p 			// Calculate pryamid stuct base address
		
	str wzr, [p_base_r, py_cen + py_x] 	// p.center.x = 0
	str wzr, [p_base_r, py_cen + py_y] 	// p.center.y = 0
	
	str w0, [p_base_r, py_bas + py_wid] 	// p.base.width = width 
	str w1, [p_base_r, py_bas + py_len] 	// p.base.length = length
	str w2, [p_base_r, py_hi] 		// p.height = height 

	
	ldr x10, [p_base_r, py_cen + py_x] 	// Store x coord on x8
	str x10, [x8, py_cen + py_x] 	
	ldr x10, [p_base_r, py_cen + py_y]	// Store y coord on x8 
	str x10, [x8, py_cen + py_y]
	
	ldr x10, [p_base_r, py_bas + py_wid] 	// Store the width on x8
	str x10, [x8, py_bas + py_wid] 	
	
	ldr x10, [p_base_r, py_bas + py_len]	// Store the length on x8 
	str x10, [x8, py_bas + py_len] 		
		
	ldr x10, [p_base_r, py_hi] 		// Store the height on x8
	str x10, [x8, py_hi]		

	mov w12, 3 				// move 3 to divide 
	
	mul w0, w0, w1  			// p.base.width * p.base.length 
	mul w2, w2, w0				// p.base.width * p.base.length * p.height
	sdiv w2, w2, w12			// (p.base.width * p.base.length * p.height)/3 
	
						// Store volume on x8
	str w2, [x8, py_vol]	
	
	mov w0, 0
	mov w1, 0
	mov w2, 0 				

	ldp x29, x30, [sp], dealloc 
	ret 


printPyramid: 
	stp	x29, x30, [sp, -16]! 
	mov	fp, sp	
	 
	mov 	x28, x0
	mov 	x27, x1 

	
	 
	adrp	x0, str2
	add	w0, w0, :lo12:str2 

	ldr 	w1, [x28, py_cen + py_x] 
	ldr	w2, [x28, py_cen + py_y] 
	ldr 	w3, [x28, py_bas + py_wid]
	ldr	w4, [x28, py_bas + py_len] 	
	ldr	w5, [x28, py_hi]
	ldr 	w6, [x28, py_vol]
	bl 	printf 
	
	mov	w0,0 
	
	ldp 	x29, x30, [sp], 16
	ret 


equalSize: 
	stp	x29, x30, [sp, -16]! 
	mov	fp, sp 	
	
	mov	x27, x0			// khafre
	mov 	x28, x1			// cheops 	

	ldr 	w11, [x27, py_bas + py_wid]	
	ldr 	w12, [x28, py_bas + py_wid]	
	cmp 	w11, w12 
	b.ne 	false 
	
	ldr 	w11, [x27, py_bas + py_len]
	ldr 	w12, [x28, py_bas + py_len]
	cmp	w11, w12
	b.ne 	false 


	ldr	w11, [x27, py_hi]
	ldr	w12, [x28, py_hi]
	b.ne	false	
	
	mov 	w0,TRUE
	b	done_eq 

false:	mov	w0, FALSE 


done_eq: 	ldp 	x29, x30, [sp], 16
	ret

expand:
	stp	x29,x30, [sp, -16]! 
	mov	fp, sp 
	
	mov	x28, x0 	// mov cheops to x28
	
	ldr 	w10, [x28, py_bas + py_wid] 	// load p->base.width 
	mul	w10, w1, w10
	str 	w10, [x28, py_bas + py_wid]

 
	ldr	w11, [x28, py_bas + py_len]	// load p->base.len
	mul	w11, w1, w11
	str	w11, [x28, py_bas + py_len] 
		 
	ldr 	w12, [x28, py_hi]		// load p-> height
	mul 	w12, w1, w12
	str	w12, [x28, py_hi]
	
	mov	w13, 3				// move 3 to divide
	mul	w10, w10, w11
	mul 	w12, w12, w10 			
	sdiv	w12, w12, w13
	
	str	w12, [x28, py_vol] 		// Store the answer into volume 
			
	ldp	x29, x30, [sp], 16
	ret


relocate: 
	stp 	x29, x30, [sp, -16]!
	mov 	fp, sp 
	
	mov	x28, x0
	
	
	ldr	w10, [x28, py_cen + py_x] 
	add	w10, w10, w1 
	str 	w10, [x28, py_cen + py_x] 

	ldr	w10, [x28, py_cen + py_y]
	add	w10, w10, w2
	str	w10, [x28, py_cen + py_y] 

	

	ldp	x29, x30, [sp], 16
	ret 	

main:	stp x29, x30, [sp, alloc]!
	mov fp, sp 
	
	add x8, fp, py_k_s			// Pryamid khafre offset 
	// Initate the arguments in khafre	
	mov w0, 10 				// int width 			
	mov w1, 10				// int length
	mov w2, 9 				// int height 

	bl	newPyramid 

	add x8, fp, py_c_s			// Pryamid cheops offset 	
	// Initate the arguments in cheops 
	mov w0, 15				// int width 
	mov w1, 15 				// int length
	mov W2, 18				// int height 
	bl 	newPyramid
	
	adrp	x0, str1 
	add	w0, w0, :lo12:str1 			
	bl	printf 	
	
	add	x0, fp, py_k_s
	adrp	x1, str4
	add	w1, w1, :lo12:str4 
	bl 	printPyramid
	
	add	x0, fp, py_c_s
	adrp	x1, str5 
	add	w1, w1, :lo12:str5

	bl	printPyramid
	
	add	x0, fp, py_k_s 
	add	x1, fp, py_c_s
	bl 	equalSize 
	
	cmp 	w0, TRUE 
	b.eq	finalprint 
	
 	add	x0, fp, py_c_s
	mov 	w1, 9
	bl	expand 
	
	add	x0, fp, py_c_s
	mov	w1, 27
	mov	w2, -10 
	bl	relocate 

	
	add	x0, fp, py_k_s
	mov	w1, -23
	mov	w2, 17 
	bl	relocate
	
	
finalprint: 
	
	adrp	x0, str6 
	add	w0, w0, :lo12:str6 
	bl 	printf
	
	add 	x0, fp, py_k_s
	adrp	x1, str4
	add	w1, w1, :lo12:str4 
 
	bl 	printPyramid	
	
	add	x0, fp, py_c_s
	adrp	x1, str5 
	add	w1, w1, :lo12:str5

	bl 	printPyramid 
done: 
	mov 	w0, 0 
	
	ldp x29, x30, [sp], dealloc 
	ret 


