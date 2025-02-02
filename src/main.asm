section .note.GNU-stack noalloc noexec nowrite progbits

section .data
	arg_error db "This program only takes one argument", 10, 0
	usage db "Usage : prog [source]", 10, 0
	open_error db "Error : failed to open source file", 0
	open_mode db "r", 0

section .text
	global main
	extern printf
	extern perror
	extern fopen

main: ; (int argc, char** argv) -> int
	push rbp
	mov rbp, rsp
	sub rsp, 12

	xor edx, edx
	mov dword [rbp-4], edx

	cmp rdi, 1
	jle .print_usage
	cmp rdi, 2
	jne .arg_error
	
	mov rdi, [rsi+8]
	lea rsi, [open_mode]
	call fopen

	test rax, rax
	jz .open_error

	mov qword [rbp-12], rax ; save file pointer
	.open_error:
		lea rdi, [open_error]
		call perror

		mov edx, 1
		mov dword [rbp-4], edx
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
