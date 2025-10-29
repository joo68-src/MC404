text:
.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

middle_value_int: 
    li t1, 2
    div t0, a1, t1
    li t1, 4
    mul t0, t0, t1
    mv t1, a0
    add t1, t1, t0
    lw a0, 0(t1)
    ret

middle_value_short:
    li t1, 2
    div t0, a1, t1
    li t1, 2
    mul t0, t0, t1
    mv t1, a0
    add t1, t1, t0
    lh a0, 0(t1)
    ret

middle_value_char:
    li t1, 2
    div t0, a1, t1
    mv t1, a0
    add t1, t1, t0
    lb a0, 0(t1)
    ret

value_matrix:
    li t0, 42
    mv t1, a1
    mul t0, t1, t0
    add t0, t0, a2
    li t2, 4
    mul t0, t0, t2
    mv t1, a0
    add t0, t1, t0
    lw a0, 0(t0)
    ret
