
.text
.globl linked_list_search
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit

linked_list_search:
    # a0: head da lista
    # a1: valor buscado
    li t0, 0
    addi sp, sp, -4
    sw ra, 0(sp)
    j linked_list_search_loop
linked_list_search_loop:
    beq a0, x0, linked_list_search_not_found
    lw t1, 0(a0)
    lw t2, 4(a0)
    add t3, t1, t2
    beq t3, a1, linked_list_search_final

    addi t0, t0, 1
    lw a0, 8(a0)
    j linked_list_search_loop
linked_list_search_final:
    # retorno
    mv a0, t0
    # restaura ra
    lw ra, 0(sp)
    addi sp, sp, 4
    ret 
linked_list_search_not_found:
    # restaura ra
    lw ra, 0(sp)
    addi sp, sp, 4

    # valor de retorno
    li a0, -1
    ret

puts:
    # a0: ponteiro pro buffer com a frase
    # salva registradores e ra na pilha
    addi sp, sp, -12
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)                            # salva o endereco de retorno na pilha

    jal ra, count_caracters                 # retorna em a1 quantidade de caracteres

    mv s0, a0                               # copia ponteiro original
    mv s1, a1                               # copia contagem de caracteres (sem o \0)

    jal ra, write                           # escreve no stdin a frase sem o newline

    # escreve "na mao" o newline
    li a1, '\n'
    li a0, 1
    li a2, 1
    li a7, 64
    ecall           

    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    addi sp, sp, 12                         # desempilha o endereco da instrucao subsequente a funcao e registradores callee-saved

    li a0, 0                                # valor de retorno (sem erros)

    ret

gets:
    # a0: ponteiro pro buffer do texto
    # salva ra e registradores na pilha
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)
    # le texto
    mv s0, a0
    jal ra, read

    mv t0, x0
    bgt a0, x0, has_bytes

    sb x0, 0(s0)
    j after_term

has_bytes:
    add t0, s0, a0
    sb x0,0(t0)
after_term:
    mv a0, s0
    jal ra,count_caracters

    add t0, a0, a1
    sb x0, 0(t0)

    mv a0, s0

    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret
    
atoi:
    # salva ra e registradores
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)

    mv s0, a0                               # ponteiro do buffer
    li s1, 0                                # valor numerico
    li s2, 1                                # sinal (inicialmente +)
skip_spaces_loop:
    lb t0, 0(s0)
    beqz t0, atoi_done                      # fim da string
    li t1, ' '                              # espaço p comparacao
    beq t0, t1, skip_space
    li t1, '\t'                             # tecla tab p comparacao
    beq t0, t1, skip_space
    j check_sign_atoi
skip_space:
    addi s0, s0, 1
    j skip_spaces_loop
check_sign_atoi:                             # checa sinal na string
    lb t0, 0(s0)
    li t1, '-'
    beq t0, t1, negative
    li t1, '+'
    beq t0, t1, positive
    j parse_digits
negative:
    li s2, -1
    addi s0, s0, 1
    j parse_digits
positive:
    addi s0, s0, 1
    j parse_digits
parse_digits:
    lb t0, 0(s0)
    beqz t0, atoi_done
    li t1, '0'
    blt t0, t1, atoi_done
    li t1, '9'
    bgt t0, t1, atoi_done
    
    addi t0, t0, -48
    li t1, 10
    mul s1, s1, t1
    add s1, s1, t0

    addi s0, s0, 1
    j parse_digits
atoi_done:
    mul s1, s1, s2
    mv a0, s1                               # salva resultado no retorno

    lw s3, 0(sp)
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    ret

itoa:
    li t0, 10
    li t1, 16
    mv t2, a1
    beq a2, t1, convert_16          # checa se o numero e base 16

    li t1, 0
    blt a0, t1, minus               # checa se o valor e base 10 negativo
    j convert_10
convert_10:
    beqz a0, invert                 # se chega em \0 acaba o loop e inverte a string
    rem t3, a0, t0                  # tira o resto da div por 10   
    addi t3, t3, 48                 # transforma em caractere
    sb t3, 0(t2)                    # coloca o valor no buffer
    addi t2, t2, 1                  # percorre o buffer
    div a0, a0, t0                  # valor restante p converter
    j convert_10
convert_16:
    beqz a0, invert                 
    rem t3, a0, t1
    bge t3, t0, letters             # converte int pra char, mas se o caracter do resto for maior que 9 o sistema muda
    addi t3, t3, 48                 
    sb t3, 0(t2)                    # coloca valor no buffer
    addi t2, t2, 1  
    div a0, a0, t1
    j convert_16
minus:
    li t1, -1
    mul a0, a0, t1
    j convert_10
letters:
    addi t3, t3, 55
    sb t3, 0(t2)
    addi t2, t2, 1
    div a0, a0, t1
    j convert_16
invert:
    li t4, 1
    beq a1, t2, end_zero
    sub t2, t2, t4
    mv t5, a1
    mv t6, t2
    li t0, 0
    blt t1, t0, minus_sb
    j invert_loop
invert_loop:
    bge t5, t6, end_conversion
    lb t0, 0(t5)
    lb t1, 0(t6)
    sb t1, 0(t5)
    sb t0, 0(t6)
    addi t5, t5, 1
    addi t6, t6, -1
    j invert_loop
minus_sb:
    li t0, 45
    addi t6, t6, 1
    addi t2, t2, 1
    sb t0, 0(t6)
    j invert_loop
end_conversion:
    addi t2, t2, 1
    sb x0, 0(t2)
    mv a0, a1
    ret
end_zero:
    addi t3, zero, 48
    sb t3, 0(t2)
    addi t2, t2, 1
    sb zero, 0(t2)
    mv a0, a1
    ret

count_caracters:
    # a0: ponteiro pro buffer com a frase
    li t0, 0                                # contador de caracteres
    mv t1, a0                               # percorre a string
    addi sp, sp, -4
    sw ra, 0(sp)                            # salva endereco de chamada na pilha
    j count_caracters_loop
count_caracters_loop:
    lb t2, 0(t1)
    beq t2, x0, count_caracters_final       # se for EOF, termina loop
    li t3, '\n' 
    beq t2, t3, count_caracters_final       # se for newline, termina loop
    addi t0, t0, 1 
    addi t1, t1, 1
    j count_caracters_loop
count_caracters_final:
    lw ra, 0(sp)                            # restaura ra
    addi sp, sp, 4                          # desempilha endereco de retorno
    mv a1, t0                               # retorno com a quantidade de caracteres
    ret

read:
    li a0, 0
    mv a1, s0                               # endereco do buffer
    li a2, 256                              # tamanho do buffer
    li a7, 63                               # syscall read
    ecall
    ret

write:
    li a0, 1                                # file descriptor = 1 (stdout)
    mv a1, s0                               # buffer
    mv a2, s1                               # size
    li a7, 64                               # syscall write (64)
    ecall
    ret

exit: 
    li a7, 93
    ecall
    ret