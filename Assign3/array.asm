// File: array.asm
// Author: Konstantinos Liosis
// Date: March 2 & 3, 2020
//
// Description:
// Working with 1-dimensional arrays in memory
// Modified lecture example


define(count, 	w19)				// Loop counter
define(st_var, 	w20)				// Variable to be stored
define(a_base, 	x21)				// Base address for integer array
define(sum,	x22)				// Array sum
define(ld_var, 	x23)				// Variable to be loaded
define(long_a, 	x24)				// Register for long int a
define(long_b,	x25)				// Register for long int b
define(offset,	x26)				// Register for mem offset

ld1:	.xword	0xABCDEF1234
ld2:	.xword	0x567890ABCD

	// Equates definition
	f_r		= 16			// Frame record size
	long_int_size	= 8			// Size of long integer
	l_int_arr_len	= 2 			// Length of long integer array
	
	l_int_arr_size	= long_int_size*l_int_arr_len	// Size of long integer array
	
	int_size	= 4			// Size of integer
	int_arr_len	= 5			// Length of integer array 
	int_arr_size	= int_size*int_arr_len	// Size of integer array
	l_int_arr_off	= fr			// Memory offset for long integer array
	
	int_arr_off	= l_int_arr_off + l_int_arr_size// Memory offset for integer array (address of first element)
	
	// Amount of memory to be allocated & deallocated 
	mem_alloc	= -(f_r + l_int_arr_size + int_arr_size) & -16

fp	.req 	x29				// Register Equate assembler directive. Alias for x29
lr	.req 	x30				// Register Equate assembler directive. Alias for x30

	.balign	4				// Instructions must be word aligned
	.global main				// Make "main" visible to the OS and start the execution

main:	stp 	fp, lr, [sp, mem_alloc]!	// Save FP and LR to stack
	mov 	fp, sp				// Update FP to the current SP

//----------------------------------------------------------------------------------------------------------

	// Store 2 long integers in the suitable positions
	ldr 	x24, =ld1
	ldr	x19, [x24]
	ldr	x25, =ld2	
	ldr	x20, [x25]

	add	offset, fp, f_r			// Calculate the memory offset to access the first element
						// of the long int array and assign it to "offset" 	
	
	str	x19, [offset]			// Store the first long int
	add 	offset, offset, long_int_size
	str	x20, [offset]			// Store the second long int, by adding to the offset the size of 1 long int
						// It works, but we cannot address array element by their index. Not optimal. 
//----------------------------------------------------------------------------------------------------------

	// Create & store array values
	mov 	count, 0			// Initialize counter
	mov	x27, 32				// Assign to x27 the size of FR and 2 long ints
	add	a_base, fp, x27			// Assign to arr_base the base address of the integer array		
	mov	w27, 100			// Assign to x27 the value 100

loop1:	madd	st_var, count, w27, count	// Assign to st_var the product of "count" by 100, plus the value of "count"
	
	str	st_var,	[a_base, count, SXTW 2]	// Store st_var on the address that's equal to the sum of "a_base" plus the
						// value of "count", sign-extended to 64bits and multiplied by 2 (LSL)
						// This type of address expression is called a "scaled register offset" and
						// it's the optimal way to refer to a position in memory
	
	add 	count, count, 1			// Increment counter 

test1:	cmp 	count, 5			// Loop condition check
	b.lt 	loop1
	
//----------------------------------------------------------------------------------------------------------

	// Load & process values
	mov	count, 0			// Initialize counter
	mov	sum, 0				// Initialize sum

	// Calculate the sum of the integer array in the loop below. Use "ld_var" to load integer and "sum" 
	// for sum calculation 
loop2:						
	

test2:	cmp 	count, 5			// Loop condition check
	b.lt 	loop2

//----------------------------------------------------------------------------------------------------------

	// Load the 1st long int in "long_a", subtract the "sum" from it, assign the result to "long_b" and
	// store it in the space for the 2nd long int in memory

//----------------------------------------------------------------------------------------------------------
end:	ldp 	fp, lr, [sp], -mem_alloc	// Restore FP and LR
	ret					// Return to caller (OS)

