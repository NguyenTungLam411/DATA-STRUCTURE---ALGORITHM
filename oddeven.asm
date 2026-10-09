global _start

section .rodata
    msg_even: db `even\n`   ; Length = 5 bytes
    msg_odd:  db `odd\n`    ; Length = 4 bytes

section .text

check_even:
    push    rbp
    mov     rbp, rsp
    mov     DWORD [rbp-4], edi
    mov     eax, DWORD [rbp-4]
    and     eax, 1
    test    eax, eax        ; SAME AS and (eax, eax). if eax = 0 -> 0;if eax = 1 -> 1
							; test (eax, eax) do not write back to eax
							; and (eax, eax) DO write back to eax
    jne     .L2             ; not equal => L2 (0 - False - odd)
    mov     eax, 1          ; Return 1 (True - Even)
    jmp     .L3
.L2:
    mov     eax, 0          ; Return 0 (False - Odd)
.L3:
    pop     rbp
    ret

_start:
    mov     edi, 7          ; Number to check
    call    check_even

    cmp     eax, 1
    je      .print_even

.print_odd:
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, msg_odd
    mov     rdx, 4          ; Write 4 bytes: 'o', 'd', 'd', '\n'
    syscall
    jmp     .exit

.print_even:
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, msg_even
    mov     rdx, 5          ; Write 5 bytes: 'e', 'v', 'e', 'n', '\n'
    syscall

.exit:
    mov     rax, 60         ; sys_exit
    mov     rdi, 0			; rdi = 0 tells Linux what exit status code to return to the
							; operating system (0 typically means "success / no error").
    syscall