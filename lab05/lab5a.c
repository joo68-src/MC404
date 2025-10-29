int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

#define STDIN_FD  0
#define STDOUT_FD 1

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}


void copy(char *orig, char *dest, int firstin, int size) {
    for (int i = 0; i < size; i++) {
        dest[i] = orig[firstin + i];
    }
    dest[size] = '\0';
}

int to_int (char *string) {
    int i = 1, val = 0;
    int sinal = (string[0] == '-') ? -1 : 1;

    while (string[i] >= '0' && string[i] <= '9') {
        val = val * 10 + (string[i] - '0');
        i++;
    }

    return val * sinal;
}

int packing (int mask, int number) {
    int dest = number & mask;
    return dest;
}

int main()
{
    int mask1 = 0b111, mask2 = 0b11111111, mask3 = 0b11111, mask4 = 0b11111, mask5 = 0b11111111111;
    char str[30] = "+0003 -0002 +0025 +0030 +1000";
    char number1[6], number2[6], number3[6], number4[6], number5[6];
    int n1, n2, n3, n4, n5;
    int pack1, pack2, pack3, pack4, pack5;

    /* Read up to 20 bytes from the standard input into the str buffer */
    int n = read(STDIN_FD, str, 30);

    copy(str, number1, 0, 5);
    n1 = to_int(number1);
    pack1 = packing(mask1, n1);
    copy(str, number2, 6, 5);
    n2 = to_int(number2);
    pack2 = packing(mask2, n2);
    copy(str, number3, 12, 5);
    n3 = to_int(number3);
    pack3 = packing(mask3, n3);
    copy(str, number4, 18, 5);
    n4 = to_int(number4);
    pack4 = packing(mask4, n4);
    copy(str, number5, 24, 5);
    n5 = to_int(number5);
    pack5 = packing(mask5, n5);

    pack2 = pack2 << 3;
    pack3 = pack3 << 11;
    pack4 = pack4 << 16;
    pack5 = pack5 << 21;

    int val = pack1+pack2+pack3+pack4+pack5;

    hex_code(val);

    /* Write n bytes from the str buffer to the standard output */
    
    return 0;
}
