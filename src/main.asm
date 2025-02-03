TAPE_SIZE equ 30000

struc LoopNode
.prev: resq 1
.start: resq 1
.size:
endstruc

section .note.GNU-stack noalloc noexec nowrite progbits

section .bss
	tape resb TAPE_SIZE

section .data
	arg_error db "This program only takes one argument", 10, 0
	usage db "Usage : prog [source]", 10, 0
	open_error db "Error : failed to open source file", 0
	open_mode db "r", 0
	io_error db "IO error", 0
	unknown_error db "Unkwnown error", 0
	unmatched db "Unmatched ']'", 10, 0

section .text
	global main
	extern printf
	extern perror
	extern fopen
	extern fgetc
	extern ferror
	extern putchar
	extern getchar
	extern malloc
	extern free
	extern fseek
	extern ftell

main: ; (int argc, char** argv) -> int
	push rbp
	mov rbp, rsp
	sub rsp, 48

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
	lea rax, [tape]
	mov [rbp-24], rax
	xor rax, rax
	mov [rbp-26], al
	mov [rbp-34], rax

	.exec_loop:
		mov rdi, qword [rbp-12]
		call fgetc

		test eax, eax
		js .eof

		mov dil, [rbp-26]
		test dil, dil
		jnz .skip

		cmp rax, '>'
		je .move_right
		
		cmp rax, '<'
		je .move_left

		cmp rax, '+'
		je .inc_tape

		cmp rax, '-'
		je .dec_tape

		cmp rax, ','
		je .getchar

		cmp rax, '.'
		je .putchar
	
		cmp rax, '['
		je .loop_start

		cmp rax, ']'
		je .loop_end

		jmp .exec_loop

		.move_right:
			mov rax, [rbp-24]
			inc rax
			lea rdi, [tape+TAPE_SIZE]
			lea rdx, [tape]
			cmp rax, rdi
			cmovge rax, rdx
			mov [rbp-24], rax

			jmp .exec_loop	

		.move_left:
			mov rax, [rbp-24]
			dec rax
			lea rdi, [tape]
			lea rdx, [tape+TAPE_SIZE-1]
			cmp rax, rdi
			cmovl rax, rdx
			mov [rbp-24], rax

			jmp .exec_loop

		.inc_tape:
			mov rax, [rbp-24]
			mov dil, [rax]
			inc dil
			mov [rax], dil

			jmp .exec_loop

		.getchar:
			call getchar
			
			test eax, eax
			js .io_error

			mov rdi, [rbp-24]
			mov [rdi], al

			jmp .exec_loop

		.putchar:
			mov rdi, [rbp-24]
			movzx rdi, byte [rdi]
			call putchar

			test rax, rax
			js .io_error

			jmp .exec_loop

		.dec_tape:
			mov rax, [rbp-24]
			mov dil, [rax]
			dec dil
			mov [rax], dil

			jmp .exec_loop

		.loop_start:
			mov rax, [rbp-24]
			mov dil, [rax]
			test dil, dil
			jnz .loop_push

			mov al , 1
			mov [rbp-26], al
			
			jmp .exec_loop

			.loop_push:
				mov rdi, LoopNode.size
				call malloc

				test rax, rax
				jz .unknown_error

				mov rdi, [rbp-34]
				mov [rax+LoopNode.prev], rdi

				mov [rbp-34], rax
				
				mov rdi, [rbp-12]
				call ftell

				test rax, rax
				js .io_error

				mov rdi, [rbp-34]
				mov [rdi+LoopNode.start], rax

				jmp .exec_loop

		.loop_end:
			mov rax, [rbp-34]
			test rax, rax
			jz .unmatched

			mov rax, [rbp-24]
			mov dil, [rax]

			test dil, dil
			jz .loop_pop

			mov rax, [rbp-34]
			mov rdi, [rbp-12]
			mov rsi, [rax+LoopNode.start]
			xor rdx, rdx
			call fseek
			
			jmp .exec_loop
			
			.loop_pop:
				mov rax, [rbp-34]
				mov rdi, [rax+LoopNode.prev]
				mov [rbp-34], rdi
				mov rdi, rax
				call free

				jmp .exec_loop

		.skip:
			cmp rax, ']'
			jne .exec_loop

			xor al, al
			mov [rbp-26], al

			jmp .exec_loop

	.unmatched:
		lea rdi, [unmatched]
		xor rax, rax
		call printf

		mov edx, 1
		mov [rbp-4], edx
		jmp .exit

	.unknown_error:
		lea rdi, [unknown_error]
		call perror

		mov edx, 1
		mov [rbp-4], edx
		jmp .exit

	.eof:
		mov rdi, qword [rbp-12]
		call ferror

		test eax, eax
		jnz .io_error

		mov edx, 0
		mov dword [rbp-4], edx
		jmp .exit

	.io_error:
		lea rdi, [io_error]
		call perror

		mov edx, 1
		mov dword [rbp-4], edx
		jmp .exit

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
