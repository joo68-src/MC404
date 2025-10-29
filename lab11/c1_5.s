text:
.globl operation

operation:
    # a0 = a, a1 = b, a2 = c, a3 = d, a4 = e, a5 = f, a6 = g, a7 = h, 0(sp) = i, 4(sp) = j, 8(sp) = k, 12(sp) = l, 16(sp) = m, 20(sp) = n
    lw t1, 0(sp)            # i
    lw t2, 4(sp)            # j
    lw t3, 8(sp)            # k
    lw t4, 12(sp)           # l
    lw t5, 16(sp)           # m
    lw t6, 20(sp)           # n

    addi sp, sp, -4
    sw ra, 24(sp)

    sw a5, 0(sp)
    sw a4, 4(sp)
    sw a3, 8(sp)
    sw a2, 12(sp)
    sw a1, 16(sp)
    sw a0, 20(sp)

    mv a0, t6
    mv a1, t5
    mv a2, t4
    mv a3, t3
    mv a4, t2
    mv a5, t1

    mv t0, a6
    mv a6, a7
    mv a7, t0

    jal ra, mystery_function

    lw ra, 24(sp)
    addi sp, sp, 4
    ret
