section .bss
    queue resq 16

section .data
    newline db 10

section .text
    global _start

_start:
    ; enqueue 1
    mov rax, 1
    call enqueue

    ; enqueue 2
    mov rax, 2
    call enqueue

    ; enqueue 3
    mov rax, 3
    call enqueue

    ; enqueue 4
    mov rax, 4
    call enqueue

    ; dequeue -> 1
    call dequeue
    ; RAX = 1
    call print_number

    ; dequeue -> 2
    call dequeue
    ; RAX = 2
    call print_number

	; dequeue -> 3
    call dequeue
    ; RAX = 3
    call print_number


    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall


; ==========================================
; Queue
;
; RAX = value to enqueue
; ==========================================

enqueue:
    mov rcx, [tail]

    mov [queue + rcx*8], rax

    inc rcx
    mov [tail], rcx

    ret


; ==========================================
; dequeue
;
; Returns:
;   RAX = oldest value
; ==========================================

dequeue:
    mov rcx, [head]

    mov rax, [queue + rcx*8]

    inc rcx
    mov [head], rcx

    ret


; ==========================================
; Print RAX as decimal
; ==========================================

print_number:
    mov rbx, 10

    ; Temporary location for digits
    lea rdi, [queue + 16*8]

.convert:
    xor rdx, rdx
    div rbx

    dec rdi
    add dl, '0'
    mov [rdi], dl

    test rax, rax
    jnz .convert

    ; Calculate length
    lea rdx, [queue + 16*8]
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


section .bss
    head resq 1
    tail resq 1