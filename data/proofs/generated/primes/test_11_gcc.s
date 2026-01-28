	.file	"test_11.c"
	.text
	.p2align 4
	.globl	add
	.type	add, @function
add:
.LFB23:
	.cfi_startproc
	leal	(%rdi,%rsi), %eax
	xorl	%esi, %esi
	xorl	%edi, %edi
	ret
	.cfi_endproc
.LFE23:
	.size	add, .-add
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	movl	$6, %esi
	movl	$5, %edi
	jmp	add@PLT
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.ident	"GCC: (GNU) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
