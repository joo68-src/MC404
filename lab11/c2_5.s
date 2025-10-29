text:
.globl node_creation

node_creation:
    addi sp, sp, -12
    mv t0, sp

    li t1, 30
    li t2, 25
    li t3, 64
    li t4, -12

    sw t1, 0(t0)
    sb t2, 4(t0)
    sb t3, 5(t0)
    sh t4, 6(t0)

    mv a0, t0
    sw ra, 8(sp)
    jal ra, mystery_function

    lw ra, 8(sp)
    addi sp, sp, 12
    ret
    