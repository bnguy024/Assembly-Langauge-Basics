// File: a6.asm 
// Date: April 14, 2020
// Author: Brandon Nguyen
// UCID: 30009135
// TUTORIAL: 04	
// Desciption:
// Translate the formula for calucuting arctan into ARMv8 assembly langauge. Use of Kostas's code of readlong from tutorial 16 is heavily refrence here. 

// Define macros for heavily used registers
define(fd_r, w19)
define(nread_r, x20)
define(buf_base_r, x21)
define(neg_flag, w11)
define(i_reg, d20)
define(temp_r,d21)
define(incre_r,d23)
define(flag_r, w10)
// Make equate for external variablbe 
		.data 	
float_1:	.double 0r1.0e-13				// Initialize global var float_1 

// Define Assembler equates
        buf_size = 8						// Number of byte for buffer
        alloc = -(16 + buf_size) & -16				// Memory to allocate 
        dealloc = -alloc					// Memory for deallocation  
        buf_s = 16						// Offset for the buffer 
        AT_FDCWD = -100						// Used to inicate the pathname is relative to the program"s current directory 
	
// Define Format strings
	.text
pn:     .string "output.bin"					// pathname file to read from
error:  .string "Error opening file: %s\nAborting.\n"		// P rint in case of error
xval:   .string "%13.10f\t"					// Print x values 
arctan: .string "%13.10f\n"					// print value of arctan	
head: 	.string "x\t\tarctan(x)\n"       			// Print the header 

	.balign 4						// Instructions must be word aligned
	
 	.global main						// Make "main" visible to the OS and start the execution
	
main:   stp x29, x30, [sp, alloc]!				// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
	 mov x29, sp						// Update frame pointer (FP) to current stack pointer (SP)


 // Open existing binary file
        mov   w0, AT_FDCWD                                      // 1st arg (cwd)
        adrp  x1, pn                                            // 2nd arg (pathname)
        add   x1, x1, :lo12:pn					// Add the lower 12 bits 
        mov   w2, 0                                             // 3rd arg (read-only)
        mov   w3, 0                                             // 4th arg (not used)
        mov   x8, 56                                            // openat I/O request
        svc   0                                                 // call system function
        mov   fd_r, w0                                          // Record file descriptor

	adrp 	x0, head	 				// Load into x0 head string 
	add	x0, x0, :lo12: head 				// Set base string (12 lower-order bits) 
	bl 	printf 						// Print the inputed values 

// Do error checking for openat()
        cmp     fd_r, 0                                         // error check: branch over
        b.ge    openok                                          // if file opened successfully

        adrp    x0, error                                        // error handling code
        add     x0, x0, :lo12:error                             // 1st arg
        adrp    x1, pn         		                        // 2narg
        add     x1, x1, :lo12:pn
        bl      printf                                          // print error message
        mov     w0, -1                                          // return -1
        b       exit                                            // exit program

openok: add     buf_base_r, x29, buf_s                          // calculate buf base


// Read long ints from  binary  file one buffer at a time in a loop
top:    mov     w0, fd_r                   			// 1st arg (fd)
        mov     x1, buf_base_r             			// 2nd arg (buf)
        mov     w2, buf_size               			// 3rd arg (n)
        mov     x8, 63                     			// read I/O request
        svc     0                          			// call system function
        mov     nread_r, x0                			// record # of bytes actually read

	mov	neg_flag, 0					// Set a negative flag

	adrp 	x0, float_1  					// load into x0 the float variable 
	add	x0, x0, :lo12:float_1 				// add in the lower 12 bits 
	ldr	d9, [x0]  					// load the variable into d9 
	
	adrp 	x0, xval 					// Load into x0 the value of x 
	add 	x0, x0, :lo12:xval 				// Add in the lower 12 bits 
	ldr 	d0, [buf_base_r]  				// Load into d0 buffer
	bl 	printf						// print the value of d0 

	ldr 	d0, [buf_base_r] 				// Load into d0 the first argument 
	
	fcmp 	d0, 0.0						// Check if the value is 0.0 
	b.eq	top_p 						// if equal the skip everything and go to top_p
	
	fcmp 	d0,0.0						// Check to see if value is negative 						
	b.gt 	not_neg						// If it isnt negative goto not_neg
				
neg: 	mov	neg_flag, 1 					// If value is negative set flag to 1
	b	first 						// Go to first 
not_neg:
	mov 	neg_flag, 0  	 				// If value is not negative set flag to 0 

first:  fabs 	d0, d0 						// Take the absolute value of d0 		
	fmov 	d19, d0 					// Base = value 		
	
	fmov 	i_reg, 1.0  					// initialize i 
	fmov 	temp_r, 3.0					// initialize n 
	fmov 	incre_r, 1.0					// Use to increment i 
	mov 	flag_r, 0					// init j if 0 sub, if 1 add  
	b 	test 	   

loop: 	fmul 	d19, d19, d0 					// value *= base  
	fadd 	i_reg, i_reg, incre_r  				// i++ 
			
test: 	fcmp  	i_reg, temp_r					// i < n
	b.lt 	loop 						// go to loop
	
	fdiv 	d19, d19, temp_r				// divide the value
					
	fcmp 	d19, d9 					// compare the absolute value of x to 1
	b.le 	top_p 						// if the is le exit the function 
	
	
	cmp 	flag_r, 0 					// compare to see whether to add or subtract the vlaue 
	b.eq 	sub  						// if the value is 0 then go to sub
					
add:	ldr	d10, [buf_base_r]				// Load in the value of buffer into d10 
	fabs 	d10, d10 					// take the absolute value 

	fadd 	d10, d10, d19					// add the values together  				
	str 	d10, [buf_base_r] 				// then store it back into d10 			
	mov 	flag_r, 0					// reset the flag	
	
	b	top_e						// goto top_e 

sub: 	ldr 	d10, [buf_base_r]				// Load in the value of buffer into d10
 	fabs 	d10, d10 					// take the absolute value
  	fsub 	d10, d10, d19 					// subtract the values
	str 	d10, [buf_base_r]				// store it back into d10 
	mov 	flag_r, 1 					// reset the flag 

top_e: 
	fmov 	i_reg, 1.0					// reset i
	fmov	d24, 2.0					// move the value 2.0 into d24  
	fadd 	temp_r, temp_r, d24 				// increment n by 2.0
				
	fmov 	d19, d0 					// mov into d19 the current value of d0 				
	b 	loop 						// Goto loop 

// Do error checking for read()
top_p:	cmp      nread_r, buf_size          			// if nread != 8, then
        b.ne     end                        			// read failed, exit loop

// Print out the float value
    	adrp 	x0, arctan 					// Load into x0 arctam 
	add 	x0, x0, :lo12:arctan 				// Add the lower 12 bits 
	fmov	d0, d10						// Move d0, the current value of d10 
	ldr	d0,[buf_base_r]					// Load into d0 the buffer 
	cmp 	neg_flag, 1					// Check if the number is negative 
	b.ne	next 						// if not then go to next

mkneg:	fneg	d0, d0						// Make the number a negative 

next:	bl      printf                      			// Call printf() function
	b       top                         			// Go to top of loop

// Close the binary file
end:    mov     w0, fd_r                    			// 1st arg (fd)
        mov     x8, 57                      			// close I/O request
        svc     0                           			// call system function

        mov     w0, 0                       			// return 0
exit:   ldp     x29, x30, [sp], dealloc				// Restore FP and LR from stack 	
        ret							// Return to caller (OS) 
