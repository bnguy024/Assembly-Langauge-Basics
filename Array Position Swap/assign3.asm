// File: assign3.asm 
// Author: Brandon Nguyen
// Date: March 3, 2020
//
// Desciption: 
// Create a program that translate the given C code
// using stack to store varialbes, addressing stack variables and stack variable offsets


// Define macros 

define(ia_base, x19)
define(temp_r,	w20)
define(gap_r,w21) 
define(index_i, w22)
define(index_j, w23) 
define(array_r, w24)

str1:	.string "Unsorted array:\n"				// Print label for unsorted array 

str2:	.string "Sorted array:\n"				// Print label for sorted array 
	
str3:	.string "v[%d]: %d\n"					// Print each element 



	// Equates definition 
	size	= 100 						// Size of the array 	
	ia_size = 100 * 4 					// Allocate the amount bytes need for the size of the array 
	
	alloc	= -(16 + ia_size + 16) & 16			// Allocate memory
	dealloc = -alloc					// Deallocate memory
	
	i_s = 16						// Offset for i
	j_s = 20						// Offset for j
	ia_s = 24						// Offset for array 
	gap_s = 28						// Offset for gap
	temp_s = 32						// Offset for temp 
	
 

	fp	.req	x29					// Register Equate assembler directive. Alias for x29
	lr	.req	x30					// Register Equate assembler directive. Alias for x30

	.balign 4						// Instruction must be word aligned
	.global main						// make "main" visible to the OS and start the execution 
		

main:	stp 	x29, x30, [sp, alloc]!				// Save FP and LR to stack 	
	mov 	fp, sp						// Update FP to the current SP 
	mov 	ia_base, fp					// Calculate the address of the array
	add 	ia_base, ia_base, ia_s				// Location of the array 

	mov 	index_i, 0					// set the index i to 0
	str 	index_i, [fp, i_s]				// Write index i to the stack 

	b 	test 						// Branch to pre-test



loop:	ldr 	index_i, [fp, i_s] 				// Read index i from stack 
	bl 	rand 						// random number fuction 
	and 	array_r, w0, 0x1FF 				// and the value of random so that it is between 0 - 512
	str 	array_r, [ia_base, index_i, SXTW 2]		// Store data from array to v[i]			

	ldr 	index_i, [fp,i_s]				// Get current i from stack 
	add 	index_i, index_i, 1 				// i++
	str 	index_i, [fp,i_s] 				// Save current index i 
	

 
test:	cmp 	index_i, size					// If i < 100 	
					 
	b.lt 	loop						// Goto first loop 	


	mov 	index_i, 0					// Initialize index i to 0 
	str 	index_i, [fp, i_s]				// Write indext i to stack
	adrp 	x0, str1					// Print out first string		
	add	w0,w0, :lo12:str1 
	bl 	printf 					
 
	b 	test1a 						// Goto test2 


loop1a: ldr 	index_i, [fp, i_s] 				// Read index i from stack 	
	ldr 	array_r, [ia_base, index_i, SXTW 2]		// Read number from array 
	adrp 	x0, str3
	add 	w0, w0, :lo12:str3				// Prints out values of array 
	mov 	w1, index_i
	mov 	w2, array_r
	bl 	printf


	ldr 	index_i, [fp, i_s]				// Get index from stack
	add 	index_i, index_i, 1				// i++
	str 	index_i, [fp, i_s]				// store index to stack  

test1a: ldr 	index_i, [fp, i_s] 				// Load index from stack
	cmp 	index_i, size					// If i < 100
	b.lt 	loop1a 						// goto loop 
	
	mov	index_i, 0					// Initialize index i to 0
	str	index_i, [fp, i_s]				// write index i to stack 

	mov	gap_r, size					// Initialize gap 
	mov 	w26, 2  	
	sdiv	gap_r, gap_r, w26				// Divide 100/2 

	adrp 	x0, str2					// Print out second string		
	add	w0,w0, :lo12:str2 
	bl 	printf 		
	
	b 	test2a						// goto test2a


loop2a:	sdiv 	gap_r, gap_r,w26				// gap/=2
	str	gap_r,[fp,gap_s]		
	b	test2a

	
	

loop2b:	add 	index_i, index_i, 1				//i++
	str	index_i, [fp, i_s]				// Store to the stack 
	b	test2b


loop2c:	ldr	index_j, [fp, j_s] 				// Read index of j
	ldr 	array_r,[ia_base, index_j, SXTW 2]		// Read index j
	
	mov	temp_r, array_r 				// Temp = v[j]
	add	w27, index_j, gap_r				// j+gap
	ldr 	array_r, [ia_base, w27, SXTW 2] 
	
	mov	array_r, temp_r					// v[j+gap] = temp 
	
	str	temp_r,[ia_base, index_j, SXTW 2]		// Store v[j+gap] into temp


	sub	index_j, index_j, gap_r				//Up date the loop j-=gap 		
	


test2c: cmp	index_j, 0					// If j >= 0
	b.ge	test2c						// goto loop2b
	b	loop2b 						// goto loop2c 
	 

	
	
test2b: sub	index_i, index_j, gap_r				// initialize j 	
	b.ge	loop2c						// If i < SIZE
	b	loop2a 						// goto 2c 

  
	
	


test2a:	mov	index_i, gap_r 					// initialize i 
	str 	index_i, [fp, i_s]				// store i to the stack 

	cmp	gap_r, 0					// if gap > 0
	b.ge	loop2b 						// Goto loop 2a 
	b 	print	

print:  ldr 	index_i, [fp, i_s] 				// Read index i from stack 	
	ldr 	array_r, [ia_base, index_i, SXTW 2]		// Read number from array 
	adrp 	x0, str3
	add 	w0, w0, :lo12:str3				// Prints out values of array 
	mov 	w1, index_i
	mov 	w2, array_r
	bl 	printf

	


done:	mov 	w0, 0						// Return 0 to OS

	ldp	fp, lr, [sp], dealloc				// Deallocate stack memory	
	ret							// Return to calling code in OS		 














