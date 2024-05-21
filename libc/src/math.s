/*
 * SDPX-FileCopyrightText: 1994 DJ Delorie
 * SPDX-FileCopyrightText: 2024 KolibriOS-NG Team
 * SPDX-License-Identifier: GPL-2.0-only
 */

.data
/* FIXME: This is not thread safe! */
exp_LCW1:   .word   0
exp_LCW2:   .word   0

pow_yint:   .word   0,0
pow_LCW1:   .word   0
pow_LCW2:   .word   0

.text
LC0:    .double 0d1.0e+00
L0:     .quad   0xffffffffffffffff


.globl acos
acos:
	fldl    4(%esp)
	fld     %st(0)
	fld1
	fsub    %st(0),%st(1)
	fadd    %st(2)
	fmulp
	fsqrt
	fabs    # fix sign of zero (matters in downward rounding mode)
	fxch    %st(1)
	fpatan
	fstpl   4(%esp)
	fldl    4(%esp)
	ret


.globl asin
asin:
	fldl    4(%esp)
	mov     8(%esp),%eax
	add     %eax,%eax
	cmp     $0x00200000,%eax
	jb      1f
	fld     %st(0)
	fld1
	fsub    %st(0), %st(1)
	fadd    %st(2)
	fmulp
	fsqrt
	fpatan
	fstpl   4(%esp)
	fldl    4(%esp)
	ret
	# subnormal x, return x with underflow
1:	
    fsts    4(%esp)
	ret


.globl atan
atan:
	fldl    4(%esp)
	mov     8(%esp),%eax
	add     %eax,%eax
	cmp     $0x00200000,%eax
	jb      1f
	fld1
	fpatan
	fstpl   4(%esp)
	fldl    4(%esp)
	ret
	# subnormal x, return x with underflow
1:	
    fsts    4(%esp)
	ret


.globl atan2
atan2:
	fldl    4(%esp)
	fldl    12(%esp)
	fpatan
	fstpl   4(%esp)
	fldl    4(%esp)
	mov     8(%esp),%eax
	add     %eax,%eax
	cmp     $0x00200000,%eax
	jae     1f
		# subnormal x, return x with underflow
	fsts    4(%esp)
1:
    ret


.globl cos
cos:
    fldl    4(%esp)
    fcos
    fstsw
    sahf
    jnp     f1
    fstp    %st(0)
    fldl    L0
1:
    ret


.globl sin
sin:
    fldl    4(%esp)
    fsin
    fstsw
    sahf
    jnp     f1
    fstp    %st(0)
    fldl    L0
1:
    ret


.globl tan
tan:
    fldl    4(%esp)
    fptan
    fstsw
    fstp    %st(0)
    sahf
    jnp     f1
/*  fstp    %st(0) - if exception, there is nothing on the stack */
    fldl    L0
1:
    ret


.globl exp
exp:
    fldl    4(%esp)
    fldl2e
    fmulp
    fstcw   exp_LCW1
    fstcw   exp_LCW2
    fwait
    andw    $0xf3ff,exp_LCW2
    orw     $0x0400,exp_LCW2
    fldcw   exp_LCW2
    fldl    %st(0)
    frndint
    fldcw   exp_LCW1
    fxch    %st(1)
    fsub    %st(1),%st
    f2xm1
    faddl   LC0
    fscale
    fstp    %st(1)
    ret


.globl log
log:
    fldln2
    fldl    4(%esp)
    fyl2x
    ret
 
.globl log10
log10:
	fldlg2
	fldl    4(%esp)
	fyl2x
	fstpl   4(%esp)
	fldl    4(%esp)
	ret

.globl modf 
modf:
    pushl   %ebp
    movl    %esp,%ebp
    subl    $16,%esp
    pushl   %ebx
    fnstcw  -4(%ebp)
    fwait
    movw    -4(%ebp),%ax
    orw     $0x0c3f,%ax
    movw    %ax,-8(%ebp)
    fldcw   -8(%ebp)
    fwait
    fldl    8(%ebp)
    frndint
    fstpl   -16(%ebp)
    fwait
    movl    -16(%ebp),%edx
    movl    -12(%ebp),%ecx
    movl    16(%ebp),%ebx
    movl    %edx,(%ebx)
    movl    %ecx,4(%ebx)
    fldl    8(%ebp)
    fsubl   -16(%ebp)
    leal    -20(%ebp),%esp
    fclex
    fldcw   -4(%ebp)
    fwait
    popl    %ebx
    leave
    ret


frac:
    fstcw   pow_LCW1
    fstcw   pow_LCW2
    fwait
    andw    $0xf3ff,pow_LCW2
    orw     $0x0400,pow_LCW2
    fldcw   pow_LCW2
    fldl    %st(0)
    frndint
    fldcw   pow_LCW1
    fxch    %st(1)
    fsub    %st(1),%st
    ret
 
Lpow2:
    call    frac
    f2xm1
    faddl   LC0
    fscale
    fstp    %st(1)
    ret

.globl pow
pow:
    fldl    12(%esp)
    fldl    4(%esp)
    ftst   
    fnstsw  %ax
    sahf
    jbe     xltez
    fyl2x
    jmp     Lpow2
xltez:
    jb      xltz
    fstp    %st(0)
    ftst
    fnstsw  %ax
    sahf
    ja      ygtz
    jb      error
    fstp    %st(0)
    fld1
    fchs
error:
    fsqrt
    ret
ygtz:
    fstp    %st(0)
    fldz
    ret
xltz:
    fabs
    fxch    %st(1)
    call    frac
    ftst
    fnstsw  %ax
    fstp    %st(0)
    sahf
    je      yisint
    fstp    %st(0)
    fchs
    jmp     error
yisint:
    fistl   pow_yint
    fxch    %st(1)
    fyl2x
    call    Lpow2
    andl    $1,pow_yint
    jz      yeven
    fchs
yeven:
    ret
 

.globl sqrt
sqrt:
    fldl    4(%esp)
    fsqrt
    ret


.globl ceil
ceil:
    pushl   %ebp
    movl    %esp,%ebp
    subl    $8,%esp        
 
    fstcw   -4(%ebp)
    fwait
    movw    -4(%ebp),%ax
    andw    $0xf3ff,%ax
    orw     $0x0800,%ax
    movw    %ax,-2(%ebp)
    fldcw   -2(%ebp)
 
    fldl    8(%ebp)
    frndint
 
    fldcw   -4(%ebp)
 
    movl    %ebp,%esp
    popl    %ebp
    ret
 

.globl fabs
fabs:
    fldl    4(%esp)
    fabs
    ret
 

.globl floor
floor:
    pushl   %ebp
    movl    %esp,%ebp
    subl    $8,%esp        
 
    fstcw   -4(%ebp)
    fwait
    movw    -4(%ebp),%ax
    andw    $0xf3ff,%ax
    orw     $0x0400,%ax
    movw    %ax,-2(%ebp)
    fldcw   -2(%ebp)
 
    fldl    8(%ebp)
    frndint
 
    fldcw   -4(%ebp)
 
    movl    %ebp,%esp
    popl    %ebp
    ret


.globl fmod
fmod:
    fldl    4(%esp)
    fldl    12(%esp)
    ftst
    fnstsw  %ax
    fxch    %st(1)
    sahf
    jnz     next
    fstpl   %st(0)
    jmp     out
next:
    fprem
    fnstsw  %ax
    sahf
    jpe     next
    fstpl   %st(1)
out:
    ret
