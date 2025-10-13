	.file	"preflow.c"
	.intel_syntax noprefix
	.text
	.globl	hello
	.bss
	.align 4
	.type	hello, @object
	.size	hello, 4
hello:
	.zero	4
	.local	progname
	.comm	progname,8,8
	.section	.rodata
.LC0:
	.string	"%s: "
.LC1:
	.string	"error: %s\n"
	.text
	.globl	error
	.type	error, @function
error:
.LFB6:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 4096
	or	QWORD PTR [rsp], 0
	sub	rsp, 4096
	or	QWORD PTR [rsp], 0
	sub	rsp, 240
	mov	QWORD PTR -8424[rbp], rdi
	mov	QWORD PTR -168[rbp], rsi
	mov	QWORD PTR -160[rbp], rdx
	mov	QWORD PTR -152[rbp], rcx
	mov	QWORD PTR -144[rbp], r8
	mov	QWORD PTR -136[rbp], r9
	test	al, al
	je	.L2
	movaps	XMMWORD PTR -128[rbp], xmm0
	movaps	XMMWORD PTR -112[rbp], xmm1
	movaps	XMMWORD PTR -96[rbp], xmm2
	movaps	XMMWORD PTR -80[rbp], xmm3
	movaps	XMMWORD PTR -64[rbp], xmm4
	movaps	XMMWORD PTR -48[rbp], xmm5
	movaps	XMMWORD PTR -32[rbp], xmm6
	movaps	XMMWORD PTR -16[rbp], xmm7
.L2:
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -184[rbp], rax
	xor	eax, eax
	mov	DWORD PTR -8408[rbp], 8
	mov	DWORD PTR -8404[rbp], 48
	lea	rax, 16[rbp]
	mov	QWORD PTR -8400[rbp], rax
	lea	rax, -176[rbp]
	mov	QWORD PTR -8392[rbp], rax
	lea	rdx, -8408[rbp]
	mov	rcx, QWORD PTR -8424[rbp]
	lea	rax, -8384[rbp]
	mov	rsi, rcx
	mov	rdi, rax
	call	vsprintf@PLT
	mov	rax, QWORD PTR progname[rip]
	test	rax, rax
	je	.L3
	mov	rdx, QWORD PTR progname[rip]
	mov	rax, QWORD PTR stderr[rip]
	lea	rcx, .LC0[rip]
	mov	rsi, rcx
	mov	rdi, rax
	mov	eax, 0
	call	fprintf@PLT
.L3:
	mov	rax, QWORD PTR stderr[rip]
	lea	rdx, -8384[rbp]
	lea	rcx, .LC1[rip]
	mov	rsi, rcx
	mov	rdi, rax
	mov	eax, 0
	call	fprintf@PLT
	mov	edi, 1
	call	exit@PLT
	.cfi_endproc
.LFE6:
	.size	error, .-error
	.type	next_int, @function
next_int:
.LFB7:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	push	rbx
	sub	rsp, 24
	.cfi_offset 3, -24
	mov	DWORD PTR -24[rbp], 0
	jmp	.L6
.L7:
	mov	edx, DWORD PTR -24[rbp]
	mov	eax, edx
	sal	eax, 2
	add	eax, edx
	add	eax, eax
	mov	edx, eax
	mov	eax, DWORD PTR -20[rbp]
	add	eax, edx
	sub	eax, 48
	mov	DWORD PTR -24[rbp], eax
.L6:
	call	__ctype_b_loc@PLT
	mov	rbx, QWORD PTR [rax]
	call	getchar@PLT
	mov	DWORD PTR -20[rbp], eax
	mov	eax, DWORD PTR -20[rbp]
	cdqe
	add	rax, rax
	add	rax, rbx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 2048
	test	eax, eax
	jne	.L7
	mov	eax, DWORD PTR -24[rbp]
	mov	rbx, QWORD PTR -8[rbp]
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	next_int, .-next_int
	.section	.rodata
	.align 8
.LC2:
	.string	"out of memory: malloc(%zu) failed"
	.text
	.type	xmalloc, @function
xmalloc:
.LFB8:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	rax, QWORD PTR -24[rbp]
	mov	rdi, rax
	call	malloc@PLT
	mov	QWORD PTR -8[rbp], rax
	cmp	QWORD PTR -8[rbp], 0
	jne	.L10
	mov	rax, QWORD PTR -24[rbp]
	mov	rsi, rax
	lea	rax, .LC2[rip]
	mov	rdi, rax
	mov	eax, 0
	call	error
.L10:
	mov	rax, QWORD PTR -8[rbp]
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	xmalloc, .-xmalloc
	.type	xcalloc, @function
xcalloc:
.LFB9:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	rax, QWORD PTR -24[rbp]
	imul	rax, QWORD PTR -32[rbp]
	mov	rdi, rax
	call	xmalloc
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	imul	rax, QWORD PTR -32[rbp]
	mov	rdx, rax
	mov	rax, QWORD PTR -8[rbp]
	mov	esi, 0
	mov	rdi, rax
	call	memset@PLT
	mov	rax, QWORD PTR -8[rbp]
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	xcalloc, .-xcalloc
	.type	add_edge, @function
add_edge:
.LFB10:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	edi, 16
	call	xmalloc
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR -8[rbp]
	mov	rdx, QWORD PTR -32[rbp]
	mov	QWORD PTR [rax], rdx
	mov	rax, QWORD PTR -24[rbp]
	mov	rdx, QWORD PTR 8[rax]
	mov	rax, QWORD PTR -8[rbp]
	mov	QWORD PTR 8[rax], rdx
	mov	rax, QWORD PTR -24[rbp]
	mov	rdx, QWORD PTR -8[rbp]
	mov	QWORD PTR 8[rax], rdx
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	add_edge, .-add_edge
	.type	connect, @function
connect:
.LFB11:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR -8[rbp], rdi
	mov	QWORD PTR -16[rbp], rsi
	mov	DWORD PTR -20[rbp], edx
	mov	QWORD PTR -32[rbp], rcx
	mov	rax, QWORD PTR -32[rbp]
	mov	rdx, QWORD PTR -8[rbp]
	mov	QWORD PTR [rax], rdx
	mov	rax, QWORD PTR -32[rbp]
	mov	rdx, QWORD PTR -16[rbp]
	mov	QWORD PTR 8[rax], rdx
	mov	rax, QWORD PTR -32[rbp]
	mov	edx, DWORD PTR -20[rbp]
	mov	DWORD PTR 20[rax], edx
	mov	rdx, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR -8[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	add_edge
	mov	rdx, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR -16[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	add_edge
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	connect, .-connect
	.type	new_graph, @function
new_graph:
.LFB12:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 64
	mov	QWORD PTR -56[rbp], rdi
	mov	DWORD PTR -60[rbp], esi
	mov	DWORD PTR -64[rbp], edx
	mov	edi, 48
	call	xmalloc
	mov	QWORD PTR -24[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	edx, DWORD PTR -60[rbp]
	mov	DWORD PTR [rax], edx
	mov	rax, QWORD PTR -24[rbp]
	mov	edx, DWORD PTR -64[rbp]
	mov	DWORD PTR 4[rax], edx
	mov	eax, DWORD PTR -60[rbp]
	cdqe
	mov	esi, 24
	mov	rdi, rax
	call	xcalloc
	mov	rdx, QWORD PTR -24[rbp]
	mov	QWORD PTR 8[rdx], rax
	mov	eax, DWORD PTR -64[rbp]
	cdqe
	mov	esi, 24
	mov	rdi, rax
	call	xcalloc
	mov	rdx, QWORD PTR -24[rbp]
	mov	QWORD PTR 16[rdx], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	rdx, QWORD PTR 8[rax]
	mov	rax, QWORD PTR -24[rbp]
	mov	QWORD PTR 24[rax], rdx
	mov	rax, QWORD PTR -24[rbp]
	mov	rcx, QWORD PTR 8[rax]
	mov	eax, DWORD PTR -60[rbp]
	movsx	rdx, eax
	mov	rax, rdx
	add	rax, rax
	add	rax, rdx
	sal	rax, 3
	sub	rax, 24
	lea	rdx, [rcx+rax]
	mov	rax, QWORD PTR -24[rbp]
	mov	QWORD PTR 32[rax], rdx
	mov	rax, QWORD PTR -24[rbp]
	mov	QWORD PTR 40[rax], 0
	mov	DWORD PTR -40[rbp], 0
	jmp	.L17
.L18:
	mov	eax, 0
	call	next_int
	mov	DWORD PTR -36[rbp], eax
	mov	eax, 0
	call	next_int
	mov	DWORD PTR -32[rbp], eax
	mov	eax, 0
	call	next_int
	mov	DWORD PTR -28[rbp], eax
	mov	rax, QWORD PTR -24[rbp]
	mov	rcx, QWORD PTR 8[rax]
	mov	eax, DWORD PTR -36[rbp]
	movsx	rdx, eax
	mov	rax, rdx
	add	rax, rax
	add	rax, rdx
	sal	rax, 3
	add	rax, rcx
	mov	QWORD PTR -16[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	rcx, QWORD PTR 8[rax]
	mov	eax, DWORD PTR -32[rbp]
	movsx	rdx, eax
	mov	rax, rdx
	add	rax, rax
	add	rax, rdx
	sal	rax, 3
	add	rax, rcx
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	rcx, QWORD PTR 16[rax]
	mov	eax, DWORD PTR -40[rbp]
	movsx	rdx, eax
	mov	rax, rdx
	add	rax, rax
	add	rax, rdx
	sal	rax, 3
	add	rcx, rax
	mov	edx, DWORD PTR -28[rbp]
	mov	rsi, QWORD PTR -8[rbp]
	mov	rax, QWORD PTR -16[rbp]
	mov	rdi, rax
	call	connect
	add	DWORD PTR -40[rbp], 1
.L17:
	mov	eax, DWORD PTR -40[rbp]
	cmp	eax, DWORD PTR -64[rbp]
	jl	.L18
	mov	rax, QWORD PTR -24[rbp]
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	new_graph, .-new_graph
	.type	enter_excess, @function
enter_excess:
.LFB13:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR -8[rbp], rdi
	mov	QWORD PTR -16[rbp], rsi
	mov	rax, QWORD PTR -8[rbp]
	mov	rax, QWORD PTR 32[rax]
	cmp	QWORD PTR -16[rbp], rax
	je	.L22
	mov	rax, QWORD PTR -8[rbp]
	mov	rax, QWORD PTR 24[rax]
	cmp	QWORD PTR -16[rbp], rax
	je	.L22
	mov	rax, QWORD PTR -8[rbp]
	mov	rdx, QWORD PTR 40[rax]
	mov	rax, QWORD PTR -16[rbp]
	mov	QWORD PTR 16[rax], rdx
	mov	rax, QWORD PTR -8[rbp]
	mov	rdx, QWORD PTR -16[rbp]
	mov	QWORD PTR 40[rax], rdx
.L22:
	nop
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	enter_excess, .-enter_excess
	.type	leave_excess, @function
leave_excess:
.LFB14:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR -24[rbp], rdi
	mov	rax, QWORD PTR -24[rbp]
	mov	rax, QWORD PTR 40[rax]
	mov	QWORD PTR -8[rbp], rax
	cmp	QWORD PTR -8[rbp], 0
	je	.L24
	mov	rax, QWORD PTR -8[rbp]
	mov	rdx, QWORD PTR 16[rax]
	mov	rax, QWORD PTR -24[rbp]
	mov	QWORD PTR 40[rax], rdx
.L24:
	mov	rax, QWORD PTR -8[rbp]
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	leave_excess, .-leave_excess
	.section	.rodata
.LC3:
	.string	"preflow.c"
.LC4:
	.string	"d >= 0"
.LC5:
	.string	"u->e >= 0"
.LC6:
	.string	"abs(e->f) <= e->c"
	.text
	.type	push, @function
push:
.LFB15:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	QWORD PTR -40[rbp], rdx
	mov	QWORD PTR -48[rbp], rcx
	mov	rax, QWORD PTR -48[rbp]
	mov	rax, QWORD PTR [rax]
	cmp	QWORD PTR -32[rbp], rax
	jne	.L27
	mov	rax, QWORD PTR -32[rbp]
	mov	edx, DWORD PTR 4[rax]
	mov	rax, QWORD PTR -48[rbp]
	mov	esi, DWORD PTR 20[rax]
	mov	rax, QWORD PTR -48[rbp]
	mov	ecx, DWORD PTR 16[rax]
	mov	eax, esi
	sub	eax, ecx
	cmp	edx, eax
	cmovle	eax, edx
	mov	DWORD PTR -4[rbp], eax
	mov	rax, QWORD PTR -48[rbp]
	mov	edx, DWORD PTR 16[rax]
	mov	eax, DWORD PTR -4[rbp]
	add	edx, eax
	mov	rax, QWORD PTR -48[rbp]
	mov	DWORD PTR 16[rax], edx
	jmp	.L28
.L27:
	mov	rax, QWORD PTR -32[rbp]
	mov	edx, DWORD PTR 4[rax]
	mov	rax, QWORD PTR -48[rbp]
	mov	ecx, DWORD PTR 20[rax]
	mov	rax, QWORD PTR -48[rbp]
	mov	eax, DWORD PTR 16[rax]
	add	eax, ecx
	cmp	edx, eax
	cmovle	eax, edx
	mov	DWORD PTR -4[rbp], eax
	mov	rax, QWORD PTR -48[rbp]
	mov	eax, DWORD PTR 16[rax]
	sub	eax, DWORD PTR -4[rbp]
	mov	edx, eax
	mov	rax, QWORD PTR -48[rbp]
	mov	DWORD PTR 16[rax], edx
.L28:
	mov	rax, QWORD PTR -32[rbp]
	mov	eax, DWORD PTR 4[rax]
	sub	eax, DWORD PTR -4[rbp]
	mov	edx, eax
	mov	rax, QWORD PTR -32[rbp]
	mov	DWORD PTR 4[rax], edx
	mov	rax, QWORD PTR -40[rbp]
	mov	edx, DWORD PTR 4[rax]
	mov	eax, DWORD PTR -4[rbp]
	add	edx, eax
	mov	rax, QWORD PTR -40[rbp]
	mov	DWORD PTR 4[rax], edx
	cmp	DWORD PTR -4[rbp], 0
	jns	.L29
	lea	rax, __PRETTY_FUNCTION__.0[rip]
	mov	rcx, rax
	mov	edx, 391
	lea	rax, .LC3[rip]
	mov	rsi, rax
	lea	rax, .LC4[rip]
	mov	rdi, rax
	call	__assert_fail@PLT
.L29:
	mov	rax, QWORD PTR -32[rbp]
	mov	eax, DWORD PTR 4[rax]
	test	eax, eax
	jns	.L30
	lea	rax, __PRETTY_FUNCTION__.0[rip]
	mov	rcx, rax
	mov	edx, 392
	lea	rax, .LC3[rip]
	mov	rsi, rax
	lea	rax, .LC5[rip]
	mov	rdi, rax
	call	__assert_fail@PLT
.L30:
	mov	rax, QWORD PTR -48[rbp]
	mov	eax, DWORD PTR 16[rax]
	mov	edx, eax
	neg	edx
	cmovs	edx, eax
	mov	rax, QWORD PTR -48[rbp]
	mov	eax, DWORD PTR 20[rax]
	cmp	edx, eax
	jle	.L31
	lea	rax, __PRETTY_FUNCTION__.0[rip]
	mov	rcx, rax
	mov	edx, 393
	lea	rax, .LC3[rip]
	mov	rsi, rax
	lea	rax, .LC6[rip]
	mov	rdi, rax
	call	__assert_fail@PLT
.L31:
	mov	rax, QWORD PTR -32[rbp]
	mov	eax, DWORD PTR 4[rax]
	test	eax, eax
	jle	.L32
	mov	rdx, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR -24[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	enter_excess
.L32:
	mov	rax, QWORD PTR -40[rbp]
	mov	eax, DWORD PTR 4[rax]
	cmp	DWORD PTR -4[rbp], eax
	jne	.L34
	mov	rdx, QWORD PTR -40[rbp]
	mov	rax, QWORD PTR -24[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	enter_excess
.L34:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	push, .-push
	.type	relabel, @function
relabel:
.LFB16:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 16
	mov	QWORD PTR -8[rbp], rdi
	mov	QWORD PTR -16[rbp], rsi
	mov	eax, DWORD PTR hello[rip]
	and	eax, 4660
	mov	DWORD PTR hello[rip], eax
	mov	rax, QWORD PTR -16[rbp]
	mov	eax, DWORD PTR [rax]
	lea	edx, 1[rax]
	mov	rax, QWORD PTR -16[rbp]
	mov	DWORD PTR [rax], edx
	mov	eax, DWORD PTR hello[rip]
	and	eax, 22136
	mov	DWORD PTR hello[rip], eax
	mov	rdx, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR -8[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	enter_excess
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	relabel, .-relabel
	.type	other, @function
other:
.LFB17:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR -8[rbp], rdi
	mov	QWORD PTR -16[rbp], rsi
	mov	rax, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR [rax]
	cmp	QWORD PTR -8[rbp], rax
	jne	.L37
	mov	rax, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR 8[rax]
	jmp	.L38
.L37:
	mov	rax, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR [rax]
.L38:
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	other, .-other
	.globl	preflow
	.type	preflow, @function
preflow:
.LFB18:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 64
	mov	QWORD PTR -56[rbp], rdi
	mov	rax, QWORD PTR -56[rbp]
	mov	rax, QWORD PTR 24[rax]
	mov	QWORD PTR -16[rbp], rax
	mov	rax, QWORD PTR -56[rbp]
	mov	edx, DWORD PTR [rax]
	mov	rax, QWORD PTR -16[rbp]
	mov	DWORD PTR [rax], edx
	mov	rax, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -24[rbp], rax
	jmp	.L40
.L41:
	mov	rax, QWORD PTR -24[rbp]
	mov	rax, QWORD PTR [rax]
	mov	QWORD PTR -32[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -24[rbp], rax
	mov	rax, QWORD PTR -16[rbp]
	mov	edx, DWORD PTR 4[rax]
	mov	rax, QWORD PTR -32[rbp]
	mov	eax, DWORD PTR 20[rax]
	add	edx, eax
	mov	rax, QWORD PTR -16[rbp]
	mov	DWORD PTR 4[rax], edx
	mov	rdx, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR -16[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	other
	mov	rdi, rax
	mov	rdx, QWORD PTR -32[rbp]
	mov	rsi, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR -56[rbp]
	mov	rcx, rdx
	mov	rdx, rdi
	mov	rdi, rax
	call	push
.L40:
	cmp	QWORD PTR -24[rbp], 0
	jne	.L41
	jmp	.L42
.L51:
	mov	QWORD PTR -40[rbp], 0
	mov	rax, QWORD PTR -8[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -24[rbp], rax
	jmp	.L43
.L48:
	mov	rax, QWORD PTR -24[rbp]
	mov	rax, QWORD PTR [rax]
	mov	QWORD PTR -32[rbp], rax
	mov	rax, QWORD PTR -24[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -24[rbp], rax
	mov	rax, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR [rax]
	cmp	QWORD PTR -8[rbp], rax
	jne	.L44
	mov	rax, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -40[rbp], rax
	mov	DWORD PTR -44[rbp], 1
	jmp	.L45
.L44:
	mov	rax, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR [rax]
	mov	QWORD PTR -40[rbp], rax
	mov	DWORD PTR -44[rbp], -1
.L45:
	mov	rax, QWORD PTR -8[rbp]
	mov	edx, DWORD PTR [rax]
	mov	rax, QWORD PTR -40[rbp]
	mov	eax, DWORD PTR [rax]
	cmp	edx, eax
	jle	.L46
	mov	rax, QWORD PTR -32[rbp]
	mov	eax, DWORD PTR 16[rax]
	imul	eax, DWORD PTR -44[rbp]
	mov	edx, eax
	mov	rax, QWORD PTR -32[rbp]
	mov	eax, DWORD PTR 20[rax]
	cmp	edx, eax
	jl	.L47
.L46:
	mov	QWORD PTR -40[rbp], 0
.L43:
	cmp	QWORD PTR -24[rbp], 0
	jne	.L48
.L47:
	cmp	QWORD PTR -40[rbp], 0
	je	.L49
	mov	rcx, QWORD PTR -32[rbp]
	mov	rdx, QWORD PTR -40[rbp]
	mov	rsi, QWORD PTR -8[rbp]
	mov	rax, QWORD PTR -56[rbp]
	mov	rdi, rax
	call	push
	jmp	.L42
.L49:
	mov	rdx, QWORD PTR -8[rbp]
	mov	rax, QWORD PTR -56[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	relabel
.L42:
	mov	rax, QWORD PTR -56[rbp]
	mov	rdi, rax
	call	leave_excess
	mov	QWORD PTR -8[rbp], rax
	cmp	QWORD PTR -8[rbp], 0
	jne	.L51
	mov	rax, QWORD PTR -56[rbp]
	mov	rax, QWORD PTR 32[rax]
	mov	eax, DWORD PTR 4[rax]
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	preflow, .-preflow
	.type	free_graph, @function
free_graph:
.LFB19:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 48
	mov	QWORD PTR -40[rbp], rdi
	mov	DWORD PTR -20[rbp], 0
	jmp	.L54
.L57:
	mov	rax, QWORD PTR -40[rbp]
	mov	rcx, QWORD PTR 8[rax]
	mov	eax, DWORD PTR -20[rbp]
	movsx	rdx, eax
	mov	rax, rdx
	add	rax, rax
	add	rax, rdx
	sal	rax, 3
	add	rax, rcx
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -16[rbp], rax
	jmp	.L55
.L56:
	mov	rax, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR -16[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -8[rbp]
	mov	QWORD PTR -16[rbp], rax
.L55:
	cmp	QWORD PTR -16[rbp], 0
	jne	.L56
	add	DWORD PTR -20[rbp], 1
.L54:
	mov	rax, QWORD PTR -40[rbp]
	mov	eax, DWORD PTR [rax]
	cmp	DWORD PTR -20[rbp], eax
	jl	.L57
	mov	rax, QWORD PTR -40[rbp]
	mov	rax, QWORD PTR 8[rax]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -40[rbp]
	mov	rax, QWORD PTR 16[rax]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -40[rbp]
	mov	rdi, rax
	call	free@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE19:
	.size	free_graph, .-free_graph
	.section	.rodata
.LC7:
	.string	"f = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB20:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 48
	mov	DWORD PTR -36[rbp], edi
	mov	QWORD PTR -48[rbp], rsi
	mov	rax, QWORD PTR -48[rbp]
	mov	rax, QWORD PTR [rax]
	mov	QWORD PTR progname[rip], rax
	mov	rax, QWORD PTR stdin[rip]
	mov	QWORD PTR -16[rbp], rax
	mov	eax, 0
	call	next_int
	mov	DWORD PTR -28[rbp], eax
	mov	eax, 0
	call	next_int
	mov	DWORD PTR -24[rbp], eax
	mov	eax, 0
	call	next_int
	mov	eax, 0
	call	next_int
	mov	edx, DWORD PTR -24[rbp]
	mov	ecx, DWORD PTR -28[rbp]
	mov	rax, QWORD PTR -16[rbp]
	mov	esi, ecx
	mov	rdi, rax
	call	new_graph
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR -16[rbp]
	mov	rdi, rax
	call	fclose@PLT
	mov	rax, QWORD PTR -8[rbp]
	mov	rdi, rax
	call	preflow
	mov	DWORD PTR -20[rbp], eax
	mov	eax, DWORD PTR -20[rbp]
	mov	esi, eax
	lea	rax, .LC7[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	mov	rax, QWORD PTR -8[rbp]
	mov	rdi, rax
	call	free_graph
	mov	eax, 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE20:
	.size	main, .-main
	.section	.rodata
	.type	__PRETTY_FUNCTION__.0, @object
	.size	__PRETTY_FUNCTION__.0, 5
__PRETTY_FUNCTION__.0:
	.string	"push"
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
