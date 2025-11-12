.data
stack_top:
.skip 1024
stack_base:

isr_stack:                          # fim da pilha
.skip 1024                          # pilha alocada pra isr 
isr_stack_end:                      # base da pilha

.text
.align 4
.set CAR_BASE_ADRESS, 0xFFFF0100
.set STEERING_WHEEL, 0x20
.set ENGINE, 0x21

int_handler:
    ###### Syscall and Interrupts handler ######
    # salva o contexto
    csrrw sp, mscratch, sp
    addi sp, sp, -108
    sw a0, (sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw a7, 28(sp)
    sw s0, 32(sp)
    sw s1, 36(sp)
    sw s2, 40(sp)
    sw s3, 44(sp)
    sw s4, 48(sp)
    sw s5, 52(sp)
    sw s6, 56(sp)
    sw s7, 60(sp)
    sw s8, 64(sp)
    sw s9, 68(sp)
    sw s10, 72(sp)
    sw s11, 76(sp)
    sw t0, 80(sp)
    sw t1, 84(sp)
    sw t2, 88(sp)
    sw t3, 92(sp)
    sw t4, 96(sp)
    sw t5, 100(sp)
    sw t6, 104(sp)

    # <= Implement your syscall handler here
    # syscall_set_engine_and_steering
    # Code: 10
        # a0: Movement direction
        # a1: Steering wheel angle
    li t0, CAR_BASE_ADRESS
    li t1, STEERING_WHEEL
    li t2, ENGINE

    add t3, t0, t1     # endereco do volante
    sb a1, (t3)         # armazena angulo do volante
    li t0, CAR_BASE_ADRESS
    add t3, t0, t2     # endereco do motor
    sb a0, (t3)         # liga, desliga, ou ativa ré do motor

    # recupera contexto
    li a0, 0
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    lw a7, 28(sp)
    lw s0, 32(sp)
    lw s1, 36(sp)
    lw s2, 40(sp)
    lw s3, 44(sp)
    lw s4, 48(sp)
    lw s5, 52(sp)
    lw s6, 56(sp)
    lw s7, 60(sp)
    lw s8, 64(sp)
    lw s9, 68(sp)
    lw s10, 72(sp)
    lw s11, 76(sp)
    lw t0, 80(sp)
    lw t1, 84(sp)
    lw t2, 88(sp)
    lw t3, 92(sp)
    lw t4, 96(sp)
    lw t5, 100(sp)
    lw t6, 104(sp)
    addi sp, sp, 108
    csrrw sp, mscratch, sp

    csrr t0, mepc       # load return address (address of the instruction that invoked the syscall)
    addi t0, t0, 4      # adds 4 to the return address (to return after ecall)
    csrw mepc, t0       # stores the return address back on mepc
    mret                # Recover remaining context (pc <- mepc)


.globl _start
_start:
    # inicializa pilha do programa
    la sp, stack_base

    # inicializa pilha da excessao
    la t0, isr_stack_end
    csrw mscratch, t0
    
    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set the interrupt array.

    # Write here the code to change to user mode and call the function
    # user_main (defined in another file). Remember to initialize
    # the user stack so that your program can use it.
    csrr t1, mstatus    # Update mstatus.MPP
    li t2, ~0x1800      # field (bits 11 and 12)
    and t1, t1, t2      # with value 00 (U-mode)
    csrw mstatus, t1    # saves user mode into mstatus

    la t0, user_main    # Loads user_main
    csrw mepc, t0       # entry point into mepc

    mret                # PC <= MEPC; mode <= MPP;

.globl control_logic
control_logic:
    addi sp, sp, -4
    sw ra, (sp)

    li s1, 0
    # implement your control logic here, using only the defined syscalls
control_loop:   # a0 motor a1 volante
    addi s1, s1, 0
    li a0, 1
    li a1, -15
    li a7, 10
    ecall

    li t0, 10000
    ble s1, t0, control_loop

    lw ra, (sp)
    addi sp, sp, 4
    ret