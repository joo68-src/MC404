data:
buffer1: .space 3000
command_buffer: .space 3000

text:
.set BASE_ADRESS, 0xFFFF0100
.globl _start

_start:
    la a1, command_buffer
    li a2, 2
    jal ra, read

    la a0, command_buffer
    jal ra, check_command

    la a1, buffer1
    li a2, 8
    jal ra, write

    j exit

check_command:
    addi sp, sp, -4
    sw ra, (sp)                 # empilha ra

    lb t0, (a0)                 # checa numero do comando
    addi t0, t0, -48

    # salvar t0 (comando) antes de chamar read_string, pois read_string suja caller-saveds
    addi sp, sp, -4
    sw  t0, 0(sp)

    la a0, buffer1
    jal ra, read_string         # le a proxima string

    # restaurar t0 (comando)
    lw  t0, 0(sp)
    addi sp, sp, 4

    # checa qual comando foi e realiza operacao correspondente
    li t1, 1
    beq t0, t1, copy_paste_label

    li t1, 2
    beq t0, t1, prepare_invert

    li t1, 3
    beq t0, t1, hex_convert

    li t1, 4
    beq t0, t1, algebraic_expression

    j restore_and_ret           # restaura ra e retorna

read_string:                    # prepara loop para ler
    addi sp, sp, -4
    sw ra, 0(sp)            
    mv t0, a0
    addi t0, t0, -1
    li t1, '\n'                 # comparador
read_string_loop:               # loop que le um byte por vez ate que seja atingido newline
    addi t0, t0, 1
    mv a1, t0
    li a2, 1
    jal ra, read
    lb t2, 0(t0)
    bne t2, t1, read_string_loop
read_string_final:              # retorna 
    la a0, buffer1
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

prepare_invert:
    jal ra, invert
    j restore_and_ret

copy_paste_label:
    j restore_and_ret

hex_convert:
    j restore_and_ret

algebraic_expression:
    j restore_and_ret

invert:
    mv t0, a0
    addi sp, sp, -12            # aloca espaço para ra, a0 e t0
    sw ra, 8(sp)
    sw a0, 4(sp)
    sw t0, 0(sp)                # preserva t0 (ponteiro) antes da chamada

    mv a0, t0
    jal ra, count_char          # retorna em a0 = quantidade (inclui newline)
    addi a0, a0, -1             # remove newline da contagem

    lw t0, 0(sp)                # restaura ponteiro inicial
    add t1, t0, a0              # endereco após o ultimo caractere
    addi t1, t1, -1             # ajusta para apontar pro ultimo caractere real
invert_loop:
    lb t2, (t0)
    lb t3, (t1)
    sb t3, (t0)
    sb t2, (t1)

    addi t0, t0, 1
    addi t1, t1, -1
    ble t0, t1, invert_loop

    lw ra, 8(sp)
    lw a0, 4(sp)
    addi sp, sp, 12
    ret

count_char:
    li t0, 0
    li t1, '\n'                 # caractere de comparacao
    mv t3, a0
    addi sp, sp, -4 
    sw ra, (sp)
count_loop:
    addi t0, t0, 1              # adiciona 1 ao contador de caracteres
    lb t2, (t3)                 # carrega caractere da string para analise
    addi t3, t3, 1              # vai pro prox caractere
    bne t1, t2, count_loop      # volta pro loop e conta prox caractere se o caractere analisado nao for newline
    mv a0, t0                   # se acabou a string move a quant de caracteres pro a0
    lw ra, (sp)
    addi sp, sp, 4
    ret
    
restore_and_ret:
    lw ra, (sp)
    addi sp, sp, 4
    ret

read:                           # parametros: a1 = endereco do buffer, a2 = tamanho da string
    li a0, 0                    # file descriptor = 0 (stdin)
    li a7, 63                   # syscall read (63)
    ecall
    ret

write:                          # parametros: a1 = endereco do buffer, a2 = tamanho da string
    li a0, 1                    # file descriptor = 1 (stdout)
    li a7, 64                   # syscall write (64)
    ecall
    ret

exit:
    li a0, 0                    # exit code 0 (sucesso)
    li a7, 93                   # syscall 'exit' (93)
    ecall                       # faz a chamada de sistema
    ret
