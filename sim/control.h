#pragma once

#include "decode.h"

typedef enum {
  ALU_ADD,
  ALU_SUB,
  ALU_SLL,
  ALU_SRL,
  ALU_SRA,
  ALU_LT,
  ALU_LTU,
  ALU_XOR,
  ALU_OR,
  ALU_AND,
  ALU_EQ,
} alu_op_t;

typedef enum {
  JUMP_COND_NEVER,
  JUMP_COND_ALWAYS,
  JUMP_COND_ZERO,
  JUMP_COND_ONE,
} jump_cond_t;

typedef enum {
  RD_SRC_ALU_Y,
  RD_SRC_DMEM_RDATA,
  RD_SRC_PC_4,
} rd_src_t;

alu_op_t
control_alu_op(ins_t ins);

imm_type_t
control_imm_type(ins_t ins);

int
control_rd_wen(ins_t ins);

jump_cond_t
control_jump_cond(ins_t ins);

rd_src_t
control_rd_src(ins_t ins);
