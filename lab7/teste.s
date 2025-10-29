
.text
.globl _start

_start:
    # ------------------------------------
    # Ler número da entrada padrão
    # ------------------------------------
    li a7, 5          # syscall read_int (ALE / RARS)
    ecall
    mv s0, a0         # s0 = valor procurado

    # ------------------------------------
    # Inicializar ponteiro e índice
    # ------------------------------------
    la t0, head_node  # ponteiro para o 1º nó
    li t1, 0          # índice atual = 0

loop_nodes:
    beqz t0, not_found    # se ponteiro == 0 → fim da lista

    lw t2, 0(t0)          # VAL1
    lw t3, 4(t0)          # VAL2
    lw t4, 8(t0)          # NEXT

    add t5, t2, t3        # soma = VAL1 + VAL2
    beq t5, s0, found     # se soma == valor procurado → achou

    mv t0, t4             # t0 = ponteiro para próximo nó
    addi t1, t1, 1        # índice++
    j loop_nodes

# ------------------------------------
# Encontrou: imprime índice
# ------------------------------------
found:
    mv a0, t1
    li a7, 1              # print_int
    ecall

    li a7, 10             # exit
    ecall

# ------------------------------------
# Não encontrou: imprime -1
# ------------------------------------
not_found:
    li a0, -1
    li a7, 1              # print_int
    ecall

    li a7, 10             # exit
    ecall