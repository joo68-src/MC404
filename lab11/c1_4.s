
text:
.globl operation

operation:
    lw t1, 8(sp)
    lw t2, 16(sp)

    add t0, a1, a2           # b + c
    sub t0, t0, a5           # (b + c) - f
    add t0, t0, a7           # (b + c - f) + h
    add t0, t0, t1           # (b + c - f + h) + k
    sub t0, t0, t2           # (b + c - f + h + k) - m

    mv a0, t0                # retorno
    ret