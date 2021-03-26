//Description: Exponentiation of a floating point number (5.5) to the power of 4

define(value_r, d16)
define(i_r, w19)
define(result_r, d17)

fmt:   .string "result = %.4f\n"
init_m: .double 0r5.5

       .balign 4
power: stp   x29, x30, [sp, -16]!
       mov   x29, sp

       cmp   w0, 0          	// check if exp == 0
       b.ne  next               // branch over if not

       fmov  d0, 1.0            // return 1.0 in d0
       b     exit

next:  fmov  value_r, d0        // value = base

       mov   i_r, 2             // init i to 2
       b     test               // branch to loop test

top:   fmul  value_r, value_r,d0  // value *= base

       add   i_r, i_r, 1        // i++
test:  cmp   i_r, w0            // loop while
       b.ls  top                // i <= exp

       fmov  d0, value_r        // return value

exit:  ldp   x29, x30, [sp], 16
       ret
       
//---------------------------------------------------------------------
       .global main
main:  stp    x29, x30, [sp, -16]!
       mov    x29, sp

       adrp   x19, init_m          // get address of constant
       add    x19, x19, :lo12:init_m
       ldr    d0, [x19]            // 1st arg (base)
       mov    w0, 4                // 2nd arg (exp)
       bl     power                // call power() function
       fmov   result_r, d0         // store return value inresult

       adrp   x0, fmt              // 1st arg
       add    x0, x0, :lo12:fmt
       fmov   d0, result_r         // 2nd arg
       bl     printf               // call printf() function

       mov    w0, 0
       ldp    x29, x30, [sp], 16
       ret
