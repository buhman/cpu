#define INS_MASK 0xffffffff

#define OP_LOAD     0x03 // b0000011
#define OP_STORE    0x23 // b0100011
#define OP_BRANCH   0x63 // b1100011
#define OP_AUIPC    0x17 // b0010111
#define OP_LUI      0x37 // b0110111
#define OP_OP_IMM   0x13 // b0010011
#define OP_OP       0x33 // b0110011
#define OP_JALR     0x67 // b1100111
#define OP_JAL      0x6f // b1101111
#define OP_SYSTEM   0x73 // b1110011
#define OP_MISC_MEM 0x0f // b0001111

#define OP_MASK      (0x7f << 0)
#define FUNCT3_MASK  (0x7  << 12)
#define FUNCT7_MASK  (0x7f << 25)
#define FUNCT12_MASK (0xfff << 20)

#define R_MASK (OP_MASK | FUNCT3_MASK | FUNCT7_MASK)
#define I_MASK (OP_MASK | FUNCT3_MASK)
#define S_MASK (OP_MASK | FUNCT3_MASK)
#define B_MASK (OP_MASK | FUNCT3_MASK)
#define U_MASK (OP_MASK)
#define J_MASK (OP_MASK)

/* funct */

#define JALR_FUNCT3 (0 << 12)

#define FUNCT3_BEQ  (0x0 << 12) // b000
#define FUNCT3_BNE  (0x1 << 12) // b001
#define FUNCT3_BLT  (0x4 << 12) // b100
#define FUNCT3_BGE  (0x5 << 12) // b101
#define FUNCT3_BLTU (0x6 << 12) // b110
#define FUNCT3_BGEU (0x7 << 12) // b111

#define FUNCT3_LB  (0x0 << 12) // b000
#define FUNCT3_LH  (0x1 << 12) // b001
#define FUNCT3_LW  (0x2 << 12) // b010
#define FUNCT3_LBU (0x4 << 12) // b100
#define FUNCT3_LHU (0x5 << 12) // b101

#define FUNCT3_SB  (0x0 << 12) // b000
#define FUNCT3_SH  (0x1 << 12) // b001
#define FUNCT3_SW  (0x2 << 12) // b010

#define FUNCT3_ADD  (0x0 << 12) // b000
#define FUNCT3_SLL  (0x1 << 12) // b001
#define FUNCT3_SLT  (0x2 << 12) // b010
#define FUNCT3_SLTU (0x3 << 12) // b011
#define FUNCT3_XOR  (0x4 << 12) // b100
#define FUNCT3_SRL  (0x5 << 12) // b101
#define FUNCT3_OR   (0x6 << 12) // b110
#define FUNCT3_AND  (0x7 << 12) // b111

#define FUNCT7_ZERO (0x00 << 25) // b0000000
#define FUNCT7_ALT  (0x20 << 25) // b0100000

#define FUNCT3_FENCE (0x0 << 12) // b000

#define FUNCT12_ECALL  (0x0 << 20)
#define FUNCT12_EBREAK (0x1 << 20)

/* ins matching */

// U_MASK
#define LUI_MATCH   (OP_LUI)
#define AUIPC_MATCH (OP_AUIPC)

// J_MASK
#define JAL_MATCH   (OP_JAL)
// I_MASK
#define JALR_MATCH  (OP_JALR | JALR_FUNCT3)

// B_MASK
#define BEQ_MATCH (OP_BRANCH | FUNCT3_BEQ)
#define BNE_MATCH (OP_BRANCH | FUNCT3_BNE)
#define BLT_MATCH (OP_BRANCH | FUNCT3_BLT)
#define BGE_MATCH (OP_BRANCH | FUNCT3_BGE)
#define BLTU_MATCH (OP_BRANCH | FUNCT3_BLTU)
#define BGEU_MATCH (OP_BRANCH | FUNCT3_BGEU)

// I_MASK
#define LB_MATCH (OP_LOAD | FUNCT3_LB)
#define LH_MATCH (OP_LOAD | FUNCT3_LH)
#define LW_MATCH (OP_LOAD | FUNCT3_LW)
#define LBU_MATCH (OP_LOAD | FUNCT3_LBU)
#define LHU_MATCH (OP_LOAD | FUNCT3_LHU)

// S_MASK
#define SB_MATCH (OP_STORE | FUNCT3_SB)
#define SH_MATCH (OP_STORE | FUNCT3_SH)
#define SW_MATCH (OP_STORE | FUNCT3_SW)

// I_MASK
#define ADDI_MATCH (OP_OP_IMM | FUNCT3_ADD)
#define SLTI_MATCH (OP_OP_IMM | FUNCT3_SLT)
#define SLTIU_MATCH (OP_OP_IMM | FUNCT3_SLTU)
#define XORI_MATCH (OP_OP_IMM | FUNCT3_XOR)
#define ORI_MATCH (OP_OP_IMM | FUNCT3_OR)
#define ANDI_MATCH (OP_OP_IMM | FUNCT3_AND)

// R_MASK
#define SLLI_MATCH (OP_OP_IMM | FUNCT3_SLL | FUNCT7_ZERO)
#define SRLI_MATCH (OP_OP_IMM | FUNCT3_SRL | FUNCT7_ZERO)
#define SRAI_MATCH (OP_OP_IMM | FUNCT3_SRL | FUNCT7_ALT)

// R_MASK
#define ADD_MATCH (OP_OP | FUNCT3_ADD | FUNCT7_ZERO)
#define SUB_MATCH (OP_OP | FUNCT3_ADD | FUNCT7_ALT)
#define SLL_MATCH (OP_OP | FUNCT3_SLL | FUNCT7_ZERO)
#define SLT_MATCH (OP_OP | FUNCT3_SLT | FUNCT7_ZERO)
#define SLTU_MATCH (OP_OP | FUNCT3_SLTU | FUNCT7_ZERO)
#define XOR_MATCH (OP_OP | FUNCT3_XOR | FUNCT7_ZERO)
#define SRL_MATCH (OP_OP | FUNCT3_SRL | FUNCT7_ZERO)
#define SRA_MATCH (OP_OP | FUNCT3_SRL | FUNCT7_ALT)
#define OR_MATCH  (OP_OP | FUNCT3_OR  | FUNCT7_ZERO)
#define AND_MATCH (OP_OP | FUNCT3_AND | FUNCT7_ZERO)

// I_MASK
#define FENCE_MATCH (OP_MISC_MEM | FUNCT3_FENCE)

// INS_MASK
#define ECALL_MATCH  (OP_SYSTEM | FUNCT12_ECALL)
#define EBREAK_MATCH (OP_SYSTEM | FUNCT12_EBREAK)
