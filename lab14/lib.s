.data
_stack_top: .skip 1024
_system_time: .word 0

.section .bss:
.align 4
isr_stack:                          # fim da pilha
.skip 1024                          # pilha alocada pra isr 
isr_stack_end:                      # base da pilha

# comandos do codigo
.text
.set GPT_BASE, 0xFFFF0100
.set MIDI_BASE, 0xFFFF0300

.globl _start
.globl play_note
.globl _system_time

_start:
    # inicializa sp
    la sp, _stack_top
    addi sp, sp, 1024

    # inicializa o endereco da ISR
    la t0, main_isr
    csrw mtvec, t0

    la t0, isr_stack_end
    csrw mscratch, t0

    # configura GPT
    li t0, GPT_BASE
    addi t0, t0, 0x8
    li t1, 100
    sw t1, (t0)

    # habilita interrupcoes externas
    csrr t1, mie 
    li t2, 0x800
    or t1, t1, t2
    csrw mie, t1

    # habilita qualquer interrupcao
    csrr t1, mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    jal ra, main

main_isr:
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

    # trata a interrupcao
    la t0, _system_time
    lw t1, (t0)
    addi t1, t1, 100
    sw t1, (t0)
    # reconfigura a interrupcao periodica a cada 100 ms
    li t0, GPT_BASE
    li t1, 100
    sw t1, 8(t0)

    # recupera contexto
    lw a0, (sp)
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
    mret

play_note: 
    # a0 = ch, a1 = inst ID, a2 = note, a3 = vel, a4 = dur
    li t0, MIDI_BASE
    sh a1, 2(t0)
    sb a2, 4(t0)
    sb a3, 5(t0)
    sh a4, 6(t0)
    sb a0, (t0)

    ret
