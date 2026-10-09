global _start

section .rodata
    msg_0: db `0\n`
    msg_1: db `1\n`
    msg_2: db `2\n`

section .text

find_remainder:
    push    rbp        ; Saves _start's rbp onto the stack.
    mov     rbp, rsp
    mov     DWORD [rbp-4], edi ; edi start = 8 => DWORD [rbp-4] = 8

    ; Division by 3 using magic multiplication (1431655766)
    mov     ecx, DWORD [rbp-4] ;  DWORD [rbp-4] = 8  => ecx = 8
    movsxd  rax, ecx
	;Move with Sign-Extension Doubleword to Quadword.
	; It takes the 32-bit integer in ecx, extends its sign bit into a 64-bit value,
	;and stores the result in rax.
	;Step-by-Step Breakdown
	; ecx holds 8 (0x00000008 in 32-bit binary).
	; The highest bit (bit 31) of 8 is 0, meaning it is positive.
	;movsxd rax, ecx fills the top 32 bits of rax with 0s (to match the sign bit)
	; and copies ecx into the lower 32 bits.
	; Result: rax becomes 8 as a full 64-bit integer (0x0000000000000008).


    imul    rax, rax, 1431655766 ; num * (floor(2^32/3))
	;Multiplies the 64-bit value in rax (8) by the magic constant 1431655766
	;8 * 1431655766 = 11453246128 (Hex: {0x2AABCC700})
	;  Result in rax: 11453246128 (0x00000002AABCC700)



    shr     rax, 32 ; num bit right shift 32 digit = num/(2^32) -> result : num/3
	; 11453246128 / (2^32) = 2
	; rax = 8/3 = 2

    mov     rdx, rax        ;   rdx = 2  <-     rax = 2
    mov     eax, ecx		; ecx = 8 => eax = 8
    sar     eax, 31         ; sar eax, 31 :  creates a mask of either 0 or -1 .
	; if (eax > 0 => 0) (sign bit = 0): Shifting all bits right by 31 fills every position with 0.
	; Result in eax becomes 0 (0x00000000).
	;if (eax < 0 => -1) (sign bit = 1) : If eax was negative (sign bit = 1):
	; Shifting all bits right by 31 fills every position with 1.
	; Result in eax becomes -1 (0xFFFFFFFF in two's complement).
    ; sar copies the original sign bit into every emptied position on the left as it shifts.
    ; now eax = so now eax = 0 (0x00000000)
    sub     edx, eax
	; edx is simply the lower 32-bit portion of the full 64-bit rdx register.
	; rdx = 2 -> edx = 2
	; 2 - 0 -> edx => edx = 2

	;64-bit RDX: [================ 32 bits ================ | ================ 32 bits (EDX) ================]
	;32-bit EDX:       edx = Full 32-bit register.
	;dx = Lower 16 bits of edx.
	;dl = Lower 8 bits of dx ("Data Low").
	;dh = Upper 8 bits of dx ("Data High").


    ; Calculate remainder: ecx = num - (edx * 3)
    mov     eax, edx        ; edx = 2 => eax = 2
    add     eax, eax        ; 2+2 -> eax => eax = 4
    add     eax, edx        ; edx = 2 ; eax = 4 ; 4+2 -> eax => eax = 6
    sub     ecx, eax        ; ecx = 8 ;  eax = 6 => 8 - 6  = 2 = num % 3 -> ecx

    mov     eax, ecx        ; Return remainder (0, 1, or 2) ; ecx = 2 -> eax => eax = 2
    pop     rbp				; top of stack   ; because push rbp at the beginning
    ret

;The logic in _start is what bridges eax to rsi
_start:
    mov     edi, 33             ; Argument = 8
    call    find_remainder

    ; Check output and print
    cmp     eax, 0        ; if eax = 0 => remainder = 0 => print 0
    je      .print_0
    cmp     eax, 1        ; if eax = 1 => remainder = 1 => print 1
    je      .print_1

; else
;   msg_2: db `2\n` => print 2

.print_2:
    mov     rsi, msg_2         ; Bridge: eax (2) selects msg_2 -> stores address in rsi
    jmp     .do_print

.print_0:
    mov     rsi, msg_0        ; Bridge: eax (0) selected msg_0 -> stores address in rsi
    jmp     .do_print

.print_1:                      ; Bridge: eax (1) selected msg_1 -> stores address in rsi
    mov     rsi, msg_1

.do_print:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rdx, 2          ; 2 bytes ("N\n")
    syscall             ; Reads memory from rsi and prints to screen

;eax holds numeric 2
;       │
;       ▼ (cmp & branch)
;.print_2:
;    mov rsi, msg_2    <-- rsi now points to ASCII string "2\n" in memory
;    jmp .do_print
;       │
;       ▼
;.do_print:
;    mov rax, 1        <-- sys_write
;    mov rdi, 1        <-- stdout
;    mov rdx, 2        <-- 2 bytes
;    syscall           <-- Kernel reads memory at rsi and prints "2\n"
;mov edi, 8  ──>  find_remainder  ──>  eax = 2        ──>  cmp & jumps  ──>  mov rsi, msg_2  ──>  syscall
;(Input Data)      (Calculation)     (Numeric Result)   (Logic Bridge)   (String Pointer)     (Terminal Output)

.exit:
    mov     rax, 60         ; sys_exit
    mov     rdi, 0          ; exit code 0
    syscall