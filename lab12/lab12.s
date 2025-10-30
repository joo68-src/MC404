text:
.globl _start

.set CAR_BASE_ADRESS, 0xFFFF0100
.set STEERING_WHEEL, 0x20
.set ENGINE, 0x21
.set HAND_BREAK, 0x22
.set SEE_X, 0x10
# OBS: ENDERECO DO GPS == CAR_BASE_ADRESS

_start:
    li s1, 0
loop:
    addi s1, s1, 1

    li a1, CAR_BASE_ADRESS
    li a2, ENGINE
    add a1, a1, a2
    li a0, 1
    sb a0, (a1)                 # liga motor

    li a1, CAR_BASE_ADRESS
    li a2, STEERING_WHEEL
    add a1, a1, a2
    li a0, -15
    sb a0, (a1)                 # vira volante

    li a1, CAR_BASE_ADRESS
    li a0, 1
    sb a0, (a1)                 # ativa o GPS

    li a2, SEE_X
    add a1, a1, a2
    lw a0, (a1)                 # le o valor guardado no GPS para X

    li t0, 10000
    ble s1, t0, loop
exit:
    li a7, 93
    ecall
    ret
