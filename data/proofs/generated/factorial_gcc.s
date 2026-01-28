	.file	"factorial.c"
	.text
	.p2align 4
	.globl	factorial
	.type	factorial, @function
factorial:
.LFB23:
	.cfi_startproc
	movl	$1, %eax
	testl	%edi, %edi
	jle	.L1
	.p2align 3
	.p2align 4
	.p2align 3
.L2:
	imull	%edi, %eax
	subl	$1, %edi
	jne	.L2
.L1:
	xorl	%edi, %edi
	ret
	.cfi_endproc
.LFE23:
	.size	factorial, .-factorial
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%d\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movl	$10, %edi
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	call	factorial@PLT
	leaq	.LC0(%rip), %rsi
	movl	$2, %edi
	movl	%eax, %edx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.ident	"GCC: (GNU) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
