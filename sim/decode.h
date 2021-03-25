#pragma once

typedef enum {
  IMM_I = 0,
  IMM_S,
  IMM_B,
  IMM_U,
  IMM_J,
  IMM_NONE
} imm_type_t;

typedef enum {
  // J_MASK
  INS_JAL = 0,

  // I_MASK
  INS_JALR,

  INS_ADDI,
  INS_SLTI,
  INS_SLTIU,
  INS_XORI,
  INS_ORI,
  INS_ANDI,

  INS_FENCE,

  INS_LB,
  INS_LH,
  INS_LW,
  INS_LBU,
  INS_LHU,

  // B_MASK
  INS_BEQ,
  INS_BNE,
  INS_BLT,
  INS_BGE,
  INS_BLTU,
  INS_BGEU,

  // S_MASK
  INS_SB,
  INS_SH,
  INS_SW,

  // R_MASK
  INS_SLLI,
  INS_SRLI,
  INS_SRAI,

  INS_ADD,
  INS_SUB,
  INS_SLL,
  INS_SLT,
  INS_SLTU,
  INS_XOR,
  INS_SRL,
  INS_SRA,
  INS_OR,
  INS_AND,

  // U_MASK
  INS_LUI,
  INS_AUIPC,

  // INS_MASK
  INS_ECALL,
  INS_EBREAK,

  //
  INS_ILLEGAL
} ins_t;

int
decode_imm(imm_type_t type, int ins);

ins_t
decode_ins(int ins);
