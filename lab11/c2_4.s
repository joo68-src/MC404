text:
.globl node_op

node_op:
    lw t0, 0(a0)
    lb t1, 4(a0)
    lb t2, 5(a0)
    lh t3, 6(a0)

    add t4, t0, t1
    sub t4, t4, t2
    add t4, t4, t3

    mv a0, t4
    ret
