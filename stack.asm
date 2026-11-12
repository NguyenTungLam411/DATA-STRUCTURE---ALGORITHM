section .data
    newline db 10

section .bss
    stack resq 16
    stack_top resq 1

section .text
    global _start

_start:
    ; stack_top = 0
    mov qword [stack_top], 0
	
	;     2 
	;     1 


    ; push 1
    mov rax, 1
    call push

    ; push 2
    mov rax, 2
    call push

    ; push 3
    mov rax, 3
    call push

    ; push 14
    mov rax, 14
    call push

    ; pop() -> 14
    call pop
    ; RAX = 14
    call print_number

    ; pop() -> 3
    call pop
    ; RAX = 3
    call print_number

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall


; -------------------------
; push
; Input:  RAX = value
; -------------------------
push:
    mov rcx, [stack_top]
    mov [stack + rcx*8], rax
    inc rcx
    mov [stack_top], rcx
    ret


; -------------------------
; pop
; Output: RAX = value
; -------------------------
pop:
    mov rcx, [stack_top]
    dec rcx						; Decrease stack top (index--)
    mov [stack_top], rcx    	; Update stack top 
    mov rax, [stack + rcx*8]	; Load top element into rax
    ret


; -------------------------
; print_number
; Input: RAX = number
; -------------------------

; so the main idea is to print number digit by digit

print_number:
    mov rbx, 10
    lea rdi, [stack + 16*8]

.convert:
    xor rdx, rdx
    div rbx

    dec rdi
    add dl, '0'
    mov [rdi], dl

    test rax, rax
    jnz .convert

    ; length
    lea rdx, [stack + 16*8]
    sub rdx, rdi

    ; write(stdout, number, length)
    mov rax, 1
    mov rsi, rdi
    mov rdi, 1
    syscall

    ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ret
