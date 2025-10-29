
text:
.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -408
    sw ra, 404(sp)
    sw s0, 400(sp)

    mv s0, sp
fill_array_int_loop:
    li t5, 100
    bge t0, t5, fill_array_int_final
    slli t1, t0, 2
    add t2, s0, t1
    sw t0, 0(t2)
    addi t0, t0, 1
    j fill_array_int_loop
fill_array_int_final:
    mv a0, s0
    jal ra, mystery_function_int

    lw ra, 404(sp)
    lw s0, 400(sp)
    addi sp, sp, 408
    ret

fill_array_short:
    addi sp, sp, -208
    sw ra, 204(sp)
    sw s0, 200(sp)

    mv s0, sp
fill_array_short_loop:
    li t5, 100
    bge t0, t5, fill_array_short_final
    slli t1, t0, 1
    add t2, s0, t1
    sh t0, 0(t2)
    addi t0, t0, 1
    j fill_array_short_loop
fill_array_short_final:
    mv a0, s0
    jal ra, mystery_function_short

    lw ra, 204(sp)
    lw s0, 200(sp)
    addi sp, sp, 208
    ret


fill_array_char:
    addi sp, sp, -108
    sw ra, 104(sp)
    sw s0, 100(sp)

    mv s0, sp
fill_array_char_loop:
    li t5, 100
    bge t0, t5, fill_array_char_final
    add t2, s0, t0
    sb t0, 0(t2)
    addi t0, t0, 1
    j fill_array_char_loop
fill_array_char_final:
    mv a0, s0
    jal ra, mystery_function_char

    lw ra, 104(sp)
    lw s0, 100(sp)
    addi sp, sp, 108
    ret
