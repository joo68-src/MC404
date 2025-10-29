.text
.globl _start

# s2 = Yb, s3 = Xc, s4 = Ta, s5 = Tb, s6 = Tc, s7 = Tr
# s8 = da, s9 = db, s10 = dc
# s11 = Y, a6 = +X, s9 = -X
# s8 = (x - XC)2 + y2 = dC2

_start: 
    # LEITURA DAS ENTRADAS

    li s0, 12
    la s1, input_address_1
    jal ra, read
    li s0, 20
    la s1, input_address_2
    jal ra, read

    # conversao da primeira string em inteiros

    la a1, input_address_1
    jal ra, int_convert_first
    mv s2, a0

    addi a1, a1, 5
    jal ra, int_convert_first
    mv s3, a0

    # conversao da segunda string em inteiros

    la a1, input_address_2
    jal ra, int_convert_last
    mv s4, a0

    addi a1, a1, 5
    jal ra, int_convert_last
    mv s5, a0

    addi a1, a1, 5
    jal ra, int_convert_last
    mv s6, a0

    addi a1, a1, 5
    jal ra, int_convert_last
    mv s7, a0

    jal ra, distances               # define as distancias da, db, dc

    jal ra, find_y                  # encontra o y
    mv s11, a0

    jal ra, find_x                  # encontra duas versoes do x
    mv a6, a0                       # x positivo
    mv s9, a0                       # x negativo
    mul s9, s9, t3

    jal ra, right_x                 # acha x correto



    li s0, 12
    la s1, input_address_1
    jal ra, write

    li s0, 20
    la s1, input_address_2
    jal ra, write

    li a7, 93                       # syscall 'exit' (93)
    li a0, 0                        # exit code 0 (sucesso)
    ecall                           # faz a chamada de sistema

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# CONVERSAO DE STRING EM INTEIROS
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

# PRIMEIRA LINHA

int_convert_first:
    li a0, 0                        # inicializador de a0 (valor de retorno)
    li a5, 1000                     # MULTIPLICADOR DOS CARACTERES
    li a2, 1                        # define se o numero vai ser negativo ou positivo

    lb t3, minus                    # avalia o sinal do valor
    lb t1, 0(a1)
    beq t1, t3, negative
    addi a1, a1, 1 

    lb t1, 0(a1)                    # carrega primeiro byte do numero
    addi t1, t1, -48                # transforma valor ascii em int
    mul t2, t1, a5                  # add casa dos milhares em t2
    add a0, a0, t2                  # armazena valor numerico em a0
    div a5, a5, t0                  # atualiza a casa

    lb t1, 1(a1)                    # carrega segundo byte do numero 
    addi t1, t1, -48                # transforma ascii em numerico
    mul t2, t1, a5                  # transforma t2 em centenas
    add a0, a0, t2                  # add centenas no primeiro num
    div a5, a5, t0           

    lb t1, 2(a1)                    # terceiro byte
    addi t1, t1, -48
    mul t2, t1, a5
    add a0, a0, t2
    div a5, a5, t0

    lb t1, 3(a1)                    # quarto e ultimo byte ebaaa
    addi t1, t1, -48
    mul t2, t1, a5
    add a0, a0, t2

    mul a0, a0, a2
    ret

negative: 
    li a2, -1
    ret

# SEGUNDA LINHA

int_convert_last:
    li a0, 0                        # inicializador de a0 (valor de retorno)
    li a5, 1000                     # MULTIPLICADOR DOS CARACTERES

    lb t1, 0(a1)                    # carrega primeiro byte do numero
    addi t1, t1, -48                # transforma valor ascii em int
    mul t2, t1, a5                  # add casa dos milhares em t2
    add a0, a0, t2                  # armazena valor numerico em a0
    div a5, a5, t0                  # atualiza a casa

    lb t1, 1(a1)                    # carrega segundo byte do numero 
    addi t1, t1, -48                # transforma ascii em numerico
    mul t2, t1, a5                  # transforma t2 em centenas
    add a0, a0, t2                  # add centenas no primeiro num
    div a5, a5, t0           

    lb t1, 2(a1)                    # terceiro byte
    addi t1, t1, -48
    mul t2, t1, a5
    add a0, a0, t2
    div a5, a5, t0

    lb t1, 3(a1)                    # quarto e ultimo byte
    addi t1, t1, -48
    mul t2, t1, a5
    add a0, a0, t2
    ret

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# CONVERTER INTEIRO EM INT
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

to_ascii:                           # converte valor individualmente
    mv a3, a0

    li t0, 10                       # unidades
    rem a2, a3, t0
    addi a2, a2, 48
    sb a2, 3(a1)
    addi a2, a2, -48

    li t0, -1
    mul a2, a2, t0
    add a3, a3, a2


    li t0, 10                       # dezenas
    div a3, a3, t0
    rem a2, a3, t0
    addi a2, a2, 48
    sb a2, 2(a1)
    addi a2, a2, -48

    li t0, -1
    mul a2, a2, t0
    add a3, a3, a2


    li t0, 10                       # centenas
    div a3, a3, t0
    rem a2, a3, t0
    addi a2, a2, 48
    sb a2, 1(a1)
    addi a2, a2, -48

    li t0, -1
    mul a2, a2, t0
    add a3, a3, a2

    li t0, 10
    div a3, a3, t0
    rem a2, a3, t0

    addi a2, a2, 48                 # unidades
    sb a2, 0(a1)
    jalr a6, a7, 0

ascii_convert:                      # cuida dos numeros em conjunto
    la a1, input_address_1

    mv a0, t3
    jal a7, to_ascii
    li t0, ' '
    sb t0, 4(a1)

    addi a1, a1, 5
    mv a0, t4
    jal a7, to_ascii
    li t0, ' '
    sb t0, 4(a1)

    addi a1, a1, 5
    mv a0, t5
    jal a7, to_ascii
    li t0, ' '
    sb t0, 4(a1)

    addi a1, a1, 5
    mv a0, t6
    jal a7, to_ascii

    li t0, '\n'
    sb t0, 4(a1)

    ret



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# FUNCAO DE RAIZ QUADRADA
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

square_root:                    
    li t0, 0                        # retorno da funcao
    beq a0, t0, if_zero             # se o numero dado for 0

    li t0, 1
    beq a0, t0, if_um               # se o numero dado for 1

    li a1, 2                        # divisor do metodo
    div t2, a0, a1                  # t2 = y/2

    beqz t2, if_um
    mv a4, t2

    li t0, 0                        # contador de iteracoes
    li t1, 25                       # iteracoes maximas

    j square_root_loop

square_root_loop:
    bge t0, t1, square_root_final
    div t2, a0, a4
    add t2, t2, a4
    li a5, 2
    div a4, t2, a5

    addi t0, t0, 1
    j square_root_loop

square_root_final:
    mv a0, a4
    ret

if_zero:
    li a0, 0
    ret

if_um:
    li a0, 1
    ret

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# CALCULO DE COORDENADAS
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

distances:
    sub t2, s7, s4                  # tempo (em nanosegundos) ate a mensagem chegar de a ate mim
    li t3, 3

    mul s8, t3, t2                  # d = vt, multiplica tempo pela vel. da luz
    li t3, 10

    div s8, s8, t3                  # distancia de a em metros

    sub t2, s7, s5                  # tempo (em nanosegundos) ate a mensagem chegar de b ate mim
    li t3, 3

    mul s9, t3, t2                  # d = vt, multiplica tempo pela vel. da luz
    li t3, 10

    div s9, s9, t3                  # distancia de b em metros

    sub t2, s7, s6                  # tempo (em nanosegundos) ate a mensagem chegar de b ate mim
    li t3, 3

    mul s10, t3, t2                 # d = vt, multiplica tempo pela vel. da luz
    li t3, 10

    div s10, s10, t3                # distancia de b em metros

    ret

find_y:
    li a0, 0

    mv t3, s8                       # copia da
    slli t3, t3, 1                  # eleva ao quadrado

    mv t4, s9                       # copia db
    slli t4, t4, 1              

    mv t6, s2                       # copia Yb
    slli t6, t6, 1

    add a0, t3, t6
    sub a0, a0, t4                  # a0 = (daˆ2 + Ybˆ2 - dbˆ2)

    li t5, 2
    mul t6, t6, t5                  # t6 = 2*Yb

    div a0, a0, t6                  # a0 = (dA2 + YB2 - dB2) / 2YB

    ret

find_x:
    li t3, -1

    mv t1, s8
    slli t1, t1, 1

    mv t2, s11
    slli t2, t2, 1

    sub a0, t1, t2
    j square_root

    ret

right_x:
    li t5, -1                       # faz a equacao 3 ((x - XC)2 + y2)
    mul s8, s3, t5
    add s8, s8, s9
    slli s8, s8, 1
    slli t6, s11, 1
    add s8, s8, t6
    
    slli s10, s10, 1

    bne s8, s10, def_x              # compara com dcˆ2. se for diferente, a posicao certa e +X
    ret                             # se for igual e -X mesmo

def_x:
    mv s9, a6
    jalr x0, ra, 0

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# LEITURA E ESCRITA
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

read: # argumentos: s0 (tamanho do texto), s1 (endereco do buffer)
    li a0, 0                        # file descriptor = 0 (stdin)
    mv a1, s1                       # buffer adress to write the data
    mv a2, s0                       # size
    li a7, 63                       # syscall read (63)
    ecall
    ret

write: # argumentos: s0 (tamanho do texto), s1 (endereco do buffer)
    li a0, 1                        # file descriptor = 1 (stdout)
    mv a1, s1                       # buffer
    mv a2, s0                       # size
    li a7, 64                       # syscall write (64)
    ecall
    ret

.data

input_address_1: .skip 0xC          # buffer 12 bytes
input_address_2: .skip 0x13         # buffer 19 bytes
newline: .asciz "\n"
space: .asciz " "
plus: .asciz "+"
minus: .asciz "-"
