.text
.globl _start

_start:
    jal ra, read
    mv s0, a0                   # salva em s0 o valor de retorno de read, a quantidade de bytes lidos

    #-------------------------------------CONVERSAO DOS CARACTERES ASCII PRA INT-----------------------------------------------#
    la a1, input_address
    li t0, 10

    # INICIALIZAR REGISTRADORES
    li t3, 0                    # registrador do primeiro numero
    li t4, 0                    # registrador do segundo numero
    li t5, 0                    # registrador do terceiro numero
    li t6, 0                    # registrador do quarto numero

    jal ra, int_convert
    mv t3, a0

    addi a1, a1, 5
    jal ra, int_convert
    mv t4, a0

    addi a1, a1, 5
    jal ra, int_convert
    mv t5, a0

    addi a1, a1, 5
    jal ra, int_convert
    mv t6, a0
    #--------------------------------------------CALCULO DAS RAIZES QUADRADAS---------------------------------------------------#
    mv a0, t3
    jal ra, square_root
    mv t3, a0

    mv a0, t4
    jal ra, square_root
    mv t4, a0

    mv a0, t5
    jal ra, square_root
    mv t5, a0

    mv a0, t6
    jal ra, square_root
    mv t6, a0
    #------------------------------------------CONVERSAO DE VOLTA A ASCII E ARMAZENAMENTO NO BUFFER----------------------------#

    jal ra, ascii_convert
    li s0, 20

    jal ra, write
    li a7, 93                   # syscall 'exit' (93)
    li a0, 0                    # exit code 0 (sucesso)
    ecall                       # faz a chamada de sistema



int_convert:
    li a0, 0                    # inicializador de a0 (valor de retorno)
    li a5, 1000                 # MULTIPLICADOR DOS CARACTERES

    lb t1, 0(a1)                # carrega primeiro byte do numero
    addi t1, t1, -48            # transforma valor ascii em int
    mul t2, t1, a5              # add casa dos milhares em t2
    add a0, a0, t2              # armazena valor numerico em a0
    div a5, a5, t0              # atualiza a casa

    lb t1, 1(a1)                # carrega segundo byte do numero 
    addi t1, t1, -48            # transforma ascii em numerico
    mul t2, t1, a5              # transforma t2 em centenas
    add a0, a0, t2              # add centenas no primeiro num
    div a5, a5, t0           

    lb t1, 2(a1)                # terceiro byte
    addi t1, t1, -48
    mul t2, t1, a5
    add a0, a0, t2
    div a5, a5, t0

    lb t1, 3(a1)                # quarto e ultimo byte
    addi t1, t1, -48
    mul t2, t1, a5
    add a0, a0, t2
    ret

to_ascii: 
    mv a3, a0

    li t0, 10                   # unidades
    rem a2, a3, t0
    addi a2, a2, 48
    sb a2, 3(a1)
    addi a2, a2, -48

    li t0, -1
    mul a2, a2, t0
    add a3, a3, a2


    li t0, 10                   # dezenas
    div a3, a3, t0
    rem a2, a3, t0
    addi a2, a2, 48
    sb a2, 2(a1)
    addi a2, a2, -48

    li t0, -1
    mul a2, a2, t0
    add a3, a3, a2


    li t0, 10                   # centenas
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

    addi a2, a2, 48             # unidades
    sb a2, 0(a1)
    jalr a6, a7, 0

ascii_convert:
    la a1, input_address

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

square_root:
    li t0, 0                    # retorno da funcao
    beq a0, t0, if_zero

    li t0, 1
    beq a0, t0, if_um

    li t1, 2                    # divisor do metodo
    div t2, a0, t1              # t2 = y/2

    beqz t2, if_um
    mv a4, t2

    li t0, 0                    # contador de iteracoes
    li t1, 10                   # iteracoes maximas

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

read:
    li a0, 0                    # file descriptor = 0 (stdin)
    la a1, input_address        # buffer to write the data
    li a2, 20                   # size (reads 20 byte)
    li a7, 63                   # syscall read (63)
    ecall
    ret

write:
    li a0, 1                   # file descriptor = 1 (stdout)
    la a1, input_address       # buffer
    mv a2, s0                  # size
    li a7, 64                  # syscall write (64)
    ecall

    ret

.data

input_address: .skip 0x14       # buffer 20 bytes
newline: .asciz "\n"
space: .asciz " "