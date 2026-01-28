	.file	"test_23.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB16:
	.cfi_startproc
	movl	$23, %eax
	ret
	.cfi_endproc
.LFE16:
	.size	main, .-main
	.ident	"GCC: (GNU) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
