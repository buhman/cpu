#define LEN(a) ((sizeof a) / (sizeof a[0]))

extern int printf(const char *format, ...);

typedef struct {
  int ins;
  int val;
} test_ins_t;

static test_ins_t test_i_type[] = {
  {0xffff8f93,    -1}, // addi x31,x31,-1
  {0x800f8f93, -2048}, // addi x31,x31,-2048
  {0x7fff8f93,  2047}, // addi x31,x31,2047
};

static test_ins_t test_s_type[] = {
  {0xffffaf23,    -2}, // sw x31,-2(x31)
  {0x81ffa023, -2048}, // sw x31,-2048(x31)
  {0x7fffafa3,  2047}, // sw x31,2047(x31)
};

static test_ins_t test_b_type[] = {
  {0xffff8fe3,    -2}, // beq x31,x31,-2
  {0x01ff9463,     8}, // bne x31,x31,8
  {0x01ff8063,     0}, // beq x31,x31,0
  {0x7fff8fe3,  4094}, // beq x31,x31,4094
  {0x81ff8063, -4096}, // beq x31,x31,-4096
};

static test_ins_t test_u_type[] = {
  {0x00000fb7,          0}, // lui x31,0
  {0xffffffb7, 0xfffff000}, // lui x31,1048575
  {0x80000fb7, 0x80000000}, // lui x31,524288
};

static test_ins_t test_j_type[] = {
  {0x00400fef, 0}, // jal x31,4
  {0x00000fef, 0}, // jal x31,0
  {0xffdfffef, 0}, // jal x31,-4
};

int
main(void)
{
  int i;
  int v;

  printf("i-type\n");
  for (i = 0; i < LEN(test_i_type); i++) {
    v = decode_imm(test_i_type[i].ins, IMM_I_TYPE);
    printf("%08x % 5d = % 5d\n", v, v, test_i_type[i].val);
  }

  printf("s-type\n");
  for (i = 0; i < LEN(test_s_type); i++) {
    v = decode_imm(test_s_type[i].ins, IMM_S_TYPE);
    printf("%08x % 5d = % 5d\n", v, v, test_s_type[i].val);
  }

  printf("b-type\n");
  for (i = 0; i < LEN(test_b_type); i++) {
    v = decode_imm(test_b_type[i].ins, IMM_B_TYPE);
    printf("%08x % 5d = % 5d\n", v, v, test_b_type[i].val);
  }

  printf("u-type\n");
  for (i = 0; i < LEN(test_u_type); i++) {
    v = decode_imm(test_u_type[i].ins, IMM_U_TYPE);
    printf("%08x % 5d = % 5d\n", v, v, test_u_type[i].val);
  }

  printf("j-type\n");
  for (i = 0; i < LEN(test_j_type); i++) {
    v = decode_imm(test_j_type[i].ins, IMM_J_TYPE);
    printf("%08x % 5d = % 5d\n", v, v, test_j_type[i].val);
  }
}
