section .data
	hello db "Hello world!", 10, 0

section .text
	global main
	extern printf

main:
	lea rdi, [hello]
	xor rax, rax
	call printf

	mov rax, 0
	ret
