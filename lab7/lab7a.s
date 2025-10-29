
.data
    input_file: .asciz "image.pgm"
    buffer: .space 300000
.text
.globl _start

_start:
    jal ra, open

    jal ra, read                    # le o arquivo e salva no buffer
    mv s4, a1                       # endereco do buffer
    mv s5, s4                       # posicao atual do buffer

    jal ra, close                   # fecha o arquivo

    #--------------------------LEITURA DO BUFFER-------------------------------#
    addi s5, s5, 2
    jal ra, skip_cabecalho

    # ler largura da imagem
    jal ra, parse_number
    mv s2, a0
    jal ra, skip_cabecalho

    # ler altura da imagem
    jal ra, parse_number
    mv s3, a0
    jal ra, skip_cabecalho

    # ler maxval
    jal ra, parse_number
    mv t0, a0
    li t1, 255
    jal ra, skip_cabecalho

    # "area" da imagem (quant de pixels)
    mv t5, x0                       # resultado
    mv t6, s2                       # valor multiplicado
    mv t4, s3                       # multiplicador
loop_mult:
    beq t4, x0, mult_final
    andi t0, t4, 1
    beq t0, x0, pula_add
    add t5, t5, t6
pula_add:
    slli t6, t6, 1
    srli t4, t4, 1
    jal ra, loop_mult
mult_final:
    jal ra, setCanvasSize

    #--------------------DEFINIR PIXELS--------------------#
    mv t6, s5
    li t1, 0
eixo_y_loop:
    li t2, 0
eixo_x_loop:
    lbu t3, 0(t6)
    addi t6, t6, 1

    # set de cor
    slli t4, t3, 24
    slli t5, t3, 16
    or   t4, t4, t5
    slli t0, t3, 8
    or   t4, t4, t0
    li t5, 255
    or t4, t4, t5

    mv a0, t2
    mv a1, t1
    mv a2, t4
    li a7, 2200
    ecall

    addi t2, t2, 1
    blt t2, s2, eixo_x_loop
    addi t1, t1, 1
    blt t1, s3, eixo_y_loop
    
    #------------SAIDA DO CODIGO------------------------#
    li a0, 0
    li a7, 93
    ecall
skip_cabecalho:
skip_loop:
    lbu t0, 0(s5)
    li t1, '#'
    beq t0, t1, skip_comentario

    li t1, 10
    beq t0, t1, skip_inc
    li t1, 13
    beq t0, t1, skip_inc
    li t1, 32
    beq t0, t1, skip_inc
    li t1, 9
    beq t0, t1, skip_inc

    jalr x0, ra, 0
skip_inc:
    addi s5, s5, 1
    jal x0, skip_loop
skip_comentario:
    addi s5, s5, 1
skip_comentarios_loop:
    lbu t0, 0(s5)
    li t1, 10
    beq t0, t1, coment_final
    addi s5, s5, 1
    jal x0, skip_comentarios_loop
coment_final:
    addi s5, s5, 1
    jal x0, skip_loop

#------------------------PARSING DE VALOR------------------#
parse_number:
    li a0, 0
parse_num_loop:
    lbu t0, 0(s5)
    li t1, '0'
    blt t0, t1, parse_num_final
    li t1, '9'
    bgt t0, t1, parse_num_final
    addi t2, t0, -48
    slli t3, a0, 3
    slli t4, a0, 1
    add t3, t3, t4
    add a0, t3, t2
    addi s5, s5, 1
    jal x0, parse_num_loop
parse_num_final:
    jalr x0, ra, 0

setCanvasSize:
    mv a0, s2
    mv a1, s3
    li a7, 2201
    ecall
    ret

read:
    la a1, buffer                   # endereco do buffer
    li a2, 300000                   # tamanho do buffer
    li a7, 63                       # syscall read
    ecall

    ret

open:
    la a0, input_file               # address for the file path
    li a1, 0                        # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0                        # mode
    li a7, 1024                     # syscall open
    ecall
    ret

close: 
    li a0, 3                        # file descriptor (fd) 3
    li a7, 57                       # syscall close
    ecall
    ret
