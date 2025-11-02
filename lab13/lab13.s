data:
buffer1: .space 3000
buffer2: .space 3000

text:
.set BASE_ADRESS, 0xFFFF0100
.globl _start

_start:


check_command:
    addi sp, sp, -4
    sw ra, (sp) 

    lb t0, (a0)
    addi t0, t0, -48
    
    li t1, 1
    beq t0, t1, copy_paste

    li t1, 2
    beq t0, t1, invert

    li t1, 3
    beq t0, t1, hex_convert

    li t1, 4
    beq t0, t1, algebraic_expression

read:                           # parametros: a1 = endereco do buffer, a2 = tamanho da string
    li a0, 0                    # file descriptor = 0 (stdin)
    li a7, 63                   # syscall read (63)
    ecall
    ret

write:                          # parametros: a1 = endereco do buffer, a2 = tamanho da string
    li a0, 1                    # file descriptor = 1 (stdout)
    li a7, 64                   # syscall write (64)
    ecall
    ret

exit:
    li a7, 93                   # syscall 'exit' (93)
    li a0, 0                    # exit code 0 (sucesso)
    ecall                       # faz a chamada de sistema
    ret