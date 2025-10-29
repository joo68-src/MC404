
text:
.globl my_function

my_function:
    # salva os callee-saved na pilha para chamar a outra funcao
    addi sp, sp, -16
    sw a0, 12(sp)
    sw a1, 8(sp)
    sw a2, 4(sp)
    sw ra, 0(sp)

    add t0, a0, a1              # SUM 1

    mv a1, a0
    mv a0, t0
    jal ra, mystery_function    # a0 = CALL 1

    lw t1, 8(sp)                # restaura a1 (segundo valor)
    sub t0, t1, a0              # DIFF 1

    add t0, a2, t0              # a2 + DIFF 1 (SUM 2)

    mv a0, t0                   # a0 = SUM 2
    mv t6, a0                   # t3 = SUM 2
    lw a1, 8(sp)                # restaura segundo valor
    jal ra, mystery_function    # a0 = CALL 2

    lw a2, 4(sp)                # restaura a2
    sub t0, a2, a0              # t0 = DIFF 2
    add t3, t6, t0              # t3 = SUM 3

    lw ra, 0(sp)
    addi sp, sp, 16             # desempilha a pilha sem restaurar os valores de chamada
    mv a0, t3
    ret
