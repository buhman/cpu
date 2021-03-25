#include "rv32i.h"
#include "decode.h"

static int
ext(int s, int n)
{
  return s ? ((1 << n) - 1) << (32 - n) : 0;
}

int
decode_imm(imm_type_t type, int i)
{
  int s = i >> 31;

  switch (type) {
  case IMM_I:
    // 31 ; 30..20
    return ext(s, 21) | ((i >> 20) & 0x7ff);
  case IMM_S:
    // 31 ; 30..25 ; 11..7
    return ext(s, 21) | (((i >> 25) & 0x3f) << 5) | ((i >> 7) & 0x1f);
  case IMM_B:
    return ext(s, 20) | (((i >> 7) & 1) << 11) | (((i >> 25) & 0x3f) << 5) | (((i >> 8) & 0xf) << 1);
  case IMM_U:
    return ext(s, 1) | (((i >> 12) & 0x7ffff) << 12);
  case IMM_J:
    return ext(s, 12) | (((i >> 12) & 0xff) << 12) | (((i >> 20) & 1) << 11) | (((i >> 21) & 0x3ff) << 1);
  case IMM_NONE:
  default:
    return type;
  }
}

ins_t
decode_ins(int i)
{
  int mask;

  mask = i & J_MASK;
  switch (mask) {
  case JAL_MATCH: return INS_JAL;
  }

  mask = i & I_MASK;
  switch (mask) {
  case ADDI_MATCH: return INS_ADDI;
  case SLTI_MATCH: return INS_SLTI;
  case SLTIU_MATCH: return INS_SLTIU;
  case XORI_MATCH: return INS_XORI;
  case ORI_MATCH: return INS_ORI;
  case ANDI_MATCH: return INS_ANDI;

  case FENCE_MATCH: return INS_FENCE;

  case LB_MATCH: return INS_LB;
  case LH_MATCH: return INS_LH;
  case LW_MATCH: return INS_LW;
  case LBU_MATCH: return INS_LBU;
  case LHU_MATCH: return INS_LHU;

  case JALR_MATCH: return INS_JALR;
  }

  mask = i & B_MASK;
  switch (mask) {
  case BEQ_MATCH: return INS_BEQ;
  case BNE_MATCH: return INS_BNE;
  case BLT_MATCH: return INS_BLT;
  case BGE_MATCH: return INS_BGE;
  case BLTU_MATCH: return INS_BLTU;
  case BGEU_MATCH: return INS_BGEU;
  }

  mask = i & S_MASK;
  switch (mask) {
  case SB_MATCH: return INS_SB;
  case SH_MATCH: return INS_SH;
  case SW_MATCH: return INS_SW;
  }

  mask = i & R_MASK;
  switch (mask) {
  case SLLI_MATCH: return INS_SLLI;
  case SRLI_MATCH: return INS_SRLI;
  case SRAI_MATCH: return INS_SRAI;

  case ADD_MATCH: return INS_ADD;
  case SUB_MATCH: return INS_SUB;
  case SLL_MATCH: return INS_SLL;
  case SLT_MATCH: return INS_SLT;
  case SLTU_MATCH: return INS_SLTU;
  case XOR_MATCH: return INS_XOR;
  case SRL_MATCH: return INS_SRL;
  case SRA_MATCH: return INS_SRA;
  case OR_MATCH: return INS_OR;
  case AND_MATCH: return INS_AND;
  }

  mask = i & U_MASK;
  switch (mask) {
  case LUI_MATCH: return INS_LUI;
  case AUIPC_MATCH: return INS_AUIPC;
  }

  mask = i & INS_MASK;
  switch (mask) {
  case ECALL_MATCH: return INS_ECALL;
  case EBREAK_MATCH: return INS_EBREAK;
  }

  return INS_ILLEGAL;
}
