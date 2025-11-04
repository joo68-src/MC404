data:
buffer1: .space 3000
command_buffer: .space 2

text:
.set BASE_ADRESS, 0xFFFF0100
.globl _start

_start:
    la a1, command_buffer
    li a2, 2
    jal ra, read                # le o comando e guarda num buffer dedicado

    la a0, command_buffer
    jal ra, check_command       # checa comando dado

    la a0, buffer1
    li a1, '\n'
    jal ra, count_char          # conta caracteres da string para imprimir
    la a1, buffer1
    mv a2, a0
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
    beq t0, t1, copy_paste_call
    li t1, 2
    beq t0, t1, invert_call
    li t1, 3
    beq t0, t1, hex_call
    li t1, 4
    beq t0, t1, algebraic_call
    li t1, 5
    beq t0, t1, debugging_session

    j restore_and_ret           # nada a fazer

debugging_session:
    addi sp, sp, -12
    sw ra, (sp)
    sw a0, 4(sp)
    sw a1, 8(sp)

    la a0, buffer1
    li a1, '\n'
    jal ra, count_char

    mv a1, a0
    la a0, buffer1
    jal ra, int_convert

    la a1, buffer1
    sb a0, (a1)
    li a0, '\n'
    sb a0, 1(a1)

    lw ra, (sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi sp, sp, 12

    j restore_and_ret

/*
COMANDO 1
*/

copy_paste_call:
    jal ra, copy_paste_label
    j restore_and_ret
copy_paste_label:
    j restore_and_ret

/*
COMANDO 2
*/

invert_call:
    jal ra, invert              # chama invert diretamente (a0 já = buffer1)
    j restore_and_ret
invert:
    mv t0, a0
    addi sp, sp, -12            # aloca espaço para ra, a0 e t0
    sw ra, 8(sp)
    sw a0, 4(sp)
    sw t0, 0(sp)                # preserva t0 (ponteiro) antes da chamada

    mv a0, t0
    li a1, '\n'
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

/*
COMANDO 3
*/

hex_call:
    jal ra, prepare_hex_convert
    j restore_and_ret
prepare_hex_convert:
    addi sp, sp, -4
    sw ra, (sp)

    mv t0, a0                   # move para t0 o endereco do buffer
    li a1, '\n'                 # caractere de finalizacao
    jal ra, count_char          # conta caracteres no numero (inclui '\n')

    mv t1, a0
    addi t1, t1, -1             # remover o '\n' da contagem
    mv a0, t0
    mv a1, t1                   # a1 = quantidade de caracteres do numero (sem '\n')
    jal ra, int_convert         # converte o valor no buffer em a0

    la a1, buffer1
    jal ra, hex_convert

    j restore_and_ret

hex_convert:                     # a0 = valor, a1 = endereco do buffer
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)

    mv s0, a1                    # s0 = buffer base
    mv s1, zero                  # s1 = contador de dígitos

    # caso valor == 0 -> "0\n"
    beq a0, zero, dec_to_hex_zero
dec_to_hex_loop:
    andi t0, a0, 0xF             # nibble = a0 & 0xF
    li t1, 10
    blt t0, t1, dec_to_hex_digit_is_num
    # nibble >= 10 -> 'a' + (nibble-10)
    addi t1, t0, -10
    addi t1, t1, 'a'
    j dec_to_hex_store
dec_to_hex_digit_is_num:
    addi t1, t0, '0'
dec_to_hex_store:
    add t2, s0, s1               # t2 = buffer + count
    sb t1, 0(t2)                 # armazena dígito (invertido)
    addi s1, s1, 1
    srli a0, a0, 4               # a0 = a0 >> 4 (logical)
    bne a0, zero, dec_to_hex_loop

    # agora s1 = quantidade de dígitos, buffer[0..s1-1] contém dígitos invertidos
    # reverter em-place
    add t3, s0, zero             # t3 = start pointer
    add t4, s0, s1
    addi t4, t4, -1              # t4 = end pointer
dec_to_hex_rev_loop:
    blt t3, t4, dec_to_hex_swap
    j dec_to_hex_after_rev
dec_to_hex_swap:
    lb t5, 0(t3)
    lb t6, 0(t4)
    sb t6, 0(t3)
    sb t5, 0(t4)
    addi t3, t3, 1
    addi t4, t4, -1
    j dec_to_hex_rev_loop
dec_to_hex_after_rev:
    # adicionar newline
    add t2, s0, s1
    li t0, '\n'
    sb t0, 0(t2)
    addi s1, s1, 1

    mv a0, s0                    # retorno = endereco do buffer
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret
dec_to_hex_zero:
    li t0, '0'
    sb t0, 0(s0)
    li t0, '\n'
    addi t1, s0, 1
    sb t0, 0(t1)
    mv a0, s0
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret
    
/*
COMANDO 4
*/

algebraic_call:
    jal ra, algebraic_expression
    j restore_and_ret
algebraic_expression:
    # FAZER

/* 
FUNCOES AUXILIARES
*/

int_convert:                    # parametros: a0 = endereco do primeiro caractere | a1 = quantidade de caracteres
    # empilha endereco de retorno e caller-saveds
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    li s0, 0                    # inicializador de a0 (valor de retorno)
    li s3, 10                   # base 10

    # Loop para processar cada caractere
    mv s2, a0                   # s2 = ponteiro para o início da string
    addi a1, a1, -1             # ajusta a1 para não incluir o caractere de nova linha
int_convert_loop:
    lb s4, 0(s2)                # carrega o caractere
    addi s2, s2, 1              # move para o próximo caractere

    # Verifica se o caractere é um dígito
    li t0, '0'
    blt s4, t0, int_convert_final # se não for dígito, finaliza
    li t1, '9'
    bgt s4, t1, int_convert_final # se não for dígito, finaliza

    addi s4, s4, -48            # converte de ASCII para inteiro (0-9)

    mul s0, s0, s3              # s0 = s0 * 10 (atualiza o valor acumulado)
    add s0, s0, s4              # s0 += digit

    bne s2, a0, int_convert_loop # continua enquanto não chegar ao final da string

int_convert_final:
    mv a0, s0                   # retorno (valor em decimal)

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24

    ret

count_char:                   # parametros: a0 = endereco do buffer com string | a1 = caractere de finalizacao
    li t0, 0
    mv t1, a1                 # caractere de comparacao
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
