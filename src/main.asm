section .note.GNU-stack noalloc noexec nowrite progbits

section .data
	arg_error db "This program only takes one argument", 10, 0
	usage db "Usage : prog [source]", 10, 0

section .text
	global main
	extern printf

main: ; (int argc, char** argv) -> int
	push rbp
	mov rbp, rsp
	sub rsp, 4

	xor edx, edx
	mov dword [rbp-4], edx

	cmp rdi, 1
	jle .print_usage
	cmp rdi, 2
	jne .arg_error
	
	jmp .exit

	.arg_error:
		lea rdi, [arg_error]
		xor rax, rax
		call printf

		mov edx, 1
		mov dword [rbp-4], edx

	.print_usage:
		lea rdi, [usage]
		xor rax, rax
		call printf

	.exit:
		mov eax, dword [rbp-4]
		mov rsp, rbp
		pop rbp

		ret
