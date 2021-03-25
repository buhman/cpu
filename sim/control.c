#include "control.h"
#include "decode.h"

alu_op_t
control_alu_op(ins_t ins)
{
  switch (ins) {
  case INS_SUB:
    return ALU_SUB;
  case INS_SLLI:
  case INS_SLL:
    return ALU_SLL;
  case INS_SRLI:
  case INS_SRL:
    return ALU_SRL;
  case INS_SRAI:
  case INS_SRA:
    return ALU_SRA;
  case INS_BLT:
  case INS_BGE:
  case INS_SLTI:
  case INS_SLT:
    return ALU_LT;
  case INS_BLTU:
  case INS_BGEU:
  case INS_SLTIU:
  case INS_SLTU:
    return ALU_LTU;
  case INS_XORI:
  case INS_XOR:
    return ALU_XOR;
  case INS_ORI:
  case INS_OR:
    return ALU_OR;
  case INS_ANDI:
  case INS_AND:
    return ALU_AND;
  case INS_BEQ:
  case INS_BNE:
    return ALU_EQ;
  default:
    return ALU_ADD;
  }
}

imm_type_t
control_imm_type(ins_t ins)
{
  switch (ins) {
  case INS_JAL:
    return IMM_J;

  case INS_BEQ:
  case INS_BNE:
  case INS_BLT:
  case INS_BGE:
  case INS_BLTU:
  case INS_BGEU:
    return IMM_B;

  case INS_SB:
  case INS_SH:
  case INS_SW:
    return IMM_S;

  case INS_LUI:
  case INS_AUIPC:
    return IMM_U;

  case INS_ADDI:
  case INS_SLTI:
  case INS_SLTIU:
  case INS_XORI:
  case INS_ORI:
  case INS_ANDI:
  case INS_SLLI:
  case INS_SRLI:
  case INS_SRAI:
  case INS_LB:
  case INS_LH:
  case INS_LW:
  case INS_LBU:
  case INS_LHU:
  case INS_JALR:
    return IMM_I;

  default:
    return IMM_NONE;
  }
}

int
control_rd_wen(ins_t ins)
{
  switch (ins) {
  case INS_LUI:
  case INS_AUIPC:

  case INS_JAL:
  case INS_JALR:

  case INS_LB:
  case INS_LH:
  case INS_LW:
  case INS_LBU:
  case INS_LHU:

  case INS_ADDI:
  case INS_SLTI:
  case INS_SLTIU:
  case INS_XORI:
  case INS_ORI:
  case INS_ANDI:
  case INS_SLLI:
  case INS_SRLI:
  case INS_SRAI:

  case INS_ADD:
  case INS_SUB:
  case INS_SLL:
  case INS_SLT:
  case INS_SLTU:
  case INS_XOR:
  case INS_SRL:
  case INS_SRA:
  case INS_OR:
  case INS_AND:
    return 1;
  default:
    return 0;
  }
}

jump_cond_t
control_jump_cond(ins_t ins)
{
  switch (ins) {
  case INS_JAL:
  case INS_JALR:
    return JUMP_COND_ALWAYS;
  case INS_BNE:
  case INS_BGE:
  case INS_BGEU:
    return JUMP_COND_ZERO;
  case INS_BEQ:
  case INS_BLT:
  case INS_BLTU:
    return JUMP_COND_ONE;
  default:
    return JUMP_COND_NEVER;
  }
}

rd_src_t
control_rd_src(ins_t ins)
{
  switch (ins) {
  case INS_JAL:
  case INS_JALR:
    return RD_SRC_PC_4;
  case INS_LB:
  case INS_LBU:
  case INS_LH:
  case INS_LHU:
  case INS_LW:
    return RD_SRC_DMEM_RDATA;
  default:
    return RD_SRC_ALU_Y;
  }
}
