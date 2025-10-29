
text:
.globl operation

operation:
    li a0, 1
    li a1, -2
    li a2, 3
    li a3, -4
    li a4, 5
    li a5, -6
    li a6, 7
    li a7, -8
    
    li t0, 9
    li t1, -10
    li t2, 11
    li t3, -12
    li t4, 13
    li t5, -14

    addi sp, sp, -28
    
    sw ra, 24(sp)
    sw t5, 20(sp)
    sw t4, 16(sp)
    sw t3, 12(sp)
    sw t2, 8(sp)
    sw t1, 4(sp)
    sw t0, 0(sp)

    jal ra, mystery_function

    lw ra, 24(sp)
    addi sp, sp, 28
    ret
    