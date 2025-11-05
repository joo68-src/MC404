data:
buffer1: .space 3000
command_buffer: .space 2

text:
.set BASE_ADRESS, 0xFFFF0100
.globl _start

_start:
    la a0, command_buffer
    jal ra, read_from_serial_port                   # le o comando e guarda num buffer dedicado

    jal ra, check_command                           # checa comando dado

    la a0, buffer1
    jal ra, write_to_serial_port
    j exit

read_from_serial_port:                              # parametros: a0 = endereco do buffer
    addi sp, sp, -4
    sw ra, (sp)                                     # empilha ra

    li t0, BASE_ADRESS                              # endereco do serial port
    li t1, '\n'                                     # comparador de fim de string
    li t2, 1                                        # ativador do serial port
    mv t3, a0                                       # endereco do buffer de destino
read_loop:
    sb t2, 2(t0)
read_loop_wait:
    lb t5, 2(t0)
    bne t5, x0, read_loop_wait

    lb t4, 3(t0)
    sb t4, 0(t3)
    addi t3, t3, 1
    bne t4, t1, read_loop

    lw ra, (sp)
    addi sp, sp, 4
    ret

write_to_serial_port:                               # parametros: a0 = endereco do buffer
    addi sp, sp, -4
    sw ra, (sp)                                     # empilha ra

    li t0, BASE_ADRESS
    li t1, '\n'
    li t2, 1
    mv t3, a0
write_loop:
    lb t4, 0(t3)
    sb t4, 1(t0)

    sb t2, 0(t0)
write_loop_wait:
    lb t5, 0(t0)
    bne t5, x0, write_loop_wait

    addi t3, t3, 1
    bne t4, t1, write_loop

    lw ra, (sp)
    addi sp, sp, 4
    ret

check_command:
    addi sp, sp, -4
    sw ra, (sp)                                     # empilha ra

    lb t0, (a0)                                     # checa numero do comando
    addi t0, t0, -48

    # salvar t0 (comando) antes de chamar read_string, pois read_string suja caller-saveds
    addi sp, sp, -4
    sw  t0, 0(sp)

    la a0, buffer1
    jal ra, read_from_serial_port                   # le a proxima string

    # restaurar t0 (comando)
    lw  t0, 0(sp)
    addi sp, sp, 4

    # checa qual comando foi e realiza operacao correspondente
    li t1, 1
    beq t0, t1, copy_paste_call
    li t1, 2
    beq t0, t1, invert_call
    li t1, 3
    beq t0, t1, hex_call
    li t1, 4
    beq t0, t1, algebraic_call

    j restore_and_ret

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------
COMANDO 1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

copy_paste_call:
    jal ra, copy_paste_label
    j restore_and_ret
copy_paste_label:
    j restore_and_ret

/*
COMANDO 2
*/

invert_call:
    jal ra, invert                                   # chama invert diretamente (a0 já = buffer1)
    j restore_and_ret
invert:
    mv t0, a0
    addi sp, sp, -12                                 # aloca espaço para ra, a0 e t0
    sw ra, 8(sp)                                     # empilha ra
    sw a0, 4(sp)
    sw t0, 0(sp)                                     # preserva t0 (ponteiro) antes da chamada

    mv a0, t0
    li a1, '\n'
    jal ra, count_char                               # retorna em a0 = quantidade (inclui newline)
    addi a0, a0, -1                                  # remove newline da contagem

    lw t0, 0(sp)                                     # restaura ponteiro inicial
    add t1, t0, a0                                   # endereco após o ultimo caractere
    addi t1, t1, -1                                  # ajusta para apontar pro ultimo caractere real
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

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------
COMANDO 3
-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/


hex_call:
    jal ra, prepare_hex_convert
    j restore_and_ret
prepare_hex_convert:
    j restore_and_ret


/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------
COMANDO 4
-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

algebraic_call:
    jal ra, algebraic_expression
    j restore_and_ret
algebraic_expression:                               # parametros: a0 = endereco do buffer com a expressao algebrica
    addi sp, sp, -24                                # empilha ra e alguns callee-saveds que talvez sejam usados
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)                                   # empilha a1 para que seja usado em outras funcoes

    mv s0, a0                                       # salva em s0 o endereco do primeiro caractere

    # a0 = buffer
    li a1, ' '
    jal ra, count_char                              # conta caracteres do primeiro valor

    mv a1, a0                                       # salva em a1 a quantidade de caracteres do primeiro valor numerico
    mv a0, s0
    jal ra, int_convert                             # a0 = valor numerico do primeiro valor da expressao
    
    mv s1, a0                                       # salva em s1 primeiro valor numerico
    add t0, s0, a1                                  # endereco do comando algebrico
    lb s2, 0(t0)                                    # salva em s2 comando algebrico


    addi a0, t0, 2                                  # endereco do segundo valor no buffer
    mv s3, a0                                       # salva endereco do segundo valor
    li a1, '\n'                                     # caractere de finalizacao do segundo valor
    jal ra, count_char                              # a0 = quant de caracteres do segundo valor

    mv a1, a0                                       # quantidade de caracteres do segundo valor
    mv a0, s3                                       # endereco do segundo valor
    jal ra, int_convert                             # retorna em a0 valor numerico do segundo numero no buffer

    mv s3, a0                                       # salva em s3 segundo valor numerico

    # s1 = primeiro valor numerico | s2 = comando algebrico | s3 = segundo valor numerico
    li t0, '+'
    beq t0, s2, addition
    li t0, '-'
    beq t0, s2, subtract
    li t0, '*'
    beq t0, s2, multiplication
    li t0, '/'
    beq t0, s2, division
    j end_expression
addition:
    add a0, s1, s3
    j end_expression
subtract:
    sub a0, s1, s3
    j end_expression
multiplication:
    mul a0, s1, s3
    j end_expression
division:
    div a0, s1, s3
    j end_expression
end_expression:
    mv a1, s0
    jal ra, ascii_convert

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24                                 # empilha ra e alguns callee-saveds que talvez sejam usados

    ret

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCOES AUXILIARES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

int_convert:                                        # parametros: a0 = endereco do primeiro caractere | a1 = quantidade de caracteres
    # empilha endereco de retorno e callee-saveds
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    li s0, 0                                        # inicializador de a0 (valor de retorno)
    li s3, 10                                       # base 10

    # Loop para processar cada caractere
    mv s2, a0                                       # s2 = ponteiro para o início da string
    addi a1, a1, -1                                 # ajusta a1 para não incluir o caractere de finalizacao
int_convert_loop:
    lb s4, 0(s2)                                    # carrega o caractere
    addi s2, s2, 1                                  # percorre string

    # Verifica se o caractere é um dígito
    li t0, '0'
    blt s4, t0, int_convert_final                   # se não for dígito, finaliza
    li t1, '9'
    bgt s4, t1, int_convert_final                   # se não for dígito, finaliza

    addi s4, s4, -48                                # converte de ASCII para inteiro (0-9)

    mul s0, s0, s3             
    add s0, s0, s4             

    bne s2, a0, int_convert_loop                    
int_convert_final:
    mv a0, s0                                       # retorno (valor em decimal)
    addi a1, a1, 1                                  # mantem a1 como estava

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24

    ret

ascii_convert:                                      # parametros: a0 = valor numerico, a1 = endereco do buffer
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)

    mv s0, a1                                       # s0 = buffer base
    li s1, 0                                        # s1 = contador de digitos
    li t0, 0                                        # t0 = flag de sinal (0 = positivo, 1 = negativo)

    beq a0, x0, ascii_zero

    blt a0, x0, ascii_make_positive
    j ascii_convert_loop
ascii_make_positive:
    li t0, 1
    sub a0, x0, a0                                  # a0 = -a0 (tornar positivo)
ascii_convert_loop:
    li t2, 10
    rem t1, a0, t2                                  # t1 = a0 % 10
    addi t1, t1, '0'                                # converte para ASCII
    add t3, s0, s1
    sb t1, 0(t3)
    addi s1, s1, 1
    div a0, a0, t2                                  # a0 = a0 / 10
    bne a0, x0, ascii_convert_loop

    # se for negativo, adiciona '-'
    beqz t0, ascii_after_digits
    li t1, '-'
    add t3, s0, s1
    sb t1, 0(t3)
    addi s1, s1, 1
ascii_after_digits:
    # reverte os caracteres armazenados (estão invertidos)
    add t3, s0, x0                                  
    add t4, s0, s1
    addi t4, t4, -1                             
ascii_rev_loop:
    blt t3, t4, ascii_rev_swap
    j ascii_rev_done
ascii_rev_swap:
    lb t5, 0(t3)
    lb t6, 0(t4)
    sb t6, 0(t3)
    sb t5, 0(t4)
    addi t3, t3, 1
    addi t4, t4, -1
    j ascii_rev_loop
ascii_rev_done:
    # adicionar newline
    add t3, s0, s1
    li t1, '\n'
    sb t1, 0(t3)
    addi s1, s1, 1

    mv a0, s0                                       # retorno = endereco do buffer
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

ascii_zero:
    li t1, '0'
    sb t1, 0(s0)
    li t1, '\n'
    addi t2, s0, 1
    sb t1, 0(t2)
    mv a0, s0
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

count_char:                                         # parametros: a0 = endereco do buffer com string | a1 = caractere de finalizacao
    li t0, 0                                        #     retorno: quant de caracteres (incluindo o caractere de finalizacao)
    mv t1, a1                                       # caractere de comparacao
    mv t3, a0
    addi sp, sp, -4 
    sw ra, (sp)
count_loop:
    addi t0, t0, 1                                  # adiciona 1 ao contador de caracteres
    lb t2, (t3)                                     # carrega caractere da string para analise
    addi t3, t3, 1                                  # vai pro prox caractere
    bne t1, t2, count_loop                          # volta pro loop e conta prox caractere se o caractere analisado nao for newline
    mv a0, t0                                       # se acabou a string move a quant de caracteres pro a0
    lw ra, (sp)
    addi sp, sp, 4
    ret
    
restore_and_ret:
    lw ra, (sp)
    addi sp, sp, 4
    ret

read_string:                                        # prepara loop para ler
    addi sp, sp, -4
    sw ra, 0(sp)            
    mv t0, a0
    addi t0, t0, -1
    li t1, '\n'                                     # comparador
read_string_loop:                                   # loop que le um byte por vez ate que seja atingido newline
    addi t0, t0, 1
    mv a1, t0
    li a2, 1
    jal ra, read
    lb t2, 0(t0)
    bne t2, t1, read_string_loop
read_string_final: 
    la a0, buffer1
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

exit:
    li a0, 0                                        # exit code 0 (sucesso)
    li a7, 93                                       # syscall 'exit' (93)
    ecall                                           # faz a chamada de sistema
    ret
