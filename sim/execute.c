#include "decode.h"
#include "execute.h"
#include "control.h"

static int
alu_execute(alu_op_t op, int a, int b)
{
  switch (op) {
  case ALU_ADD:
    return a + b;
  case ALU_SUB:
    return (signed int)a - (signed int)b;
  case ALU_SLL:
    return a << b;
  case ALU_SRL:
    return (unsigned int)a >> (unsigned int)b;
  case ALU_SRA:
    return (signed int)a >> (signed int)b;
  case ALU_LT:
    return (signed int)a < (signed int)b;
  case ALU_LTU:
    return (unsigned int)a < (unsigned int)b;
  case ALU_XOR:
    return a ^ b;
  case ALU_OR:
    return a | b;
  case ALU_AND:
    return a & b;
  case ALU_EQ:
    return a == b;
  }
  return op;
}

static int
execute_dmem(ins_t ins, int wdata, void * mem, int addr)
{
  switch (ins) {
  case INS_SB:
    *((char*)&(((char*)mem)[addr])) = (char)wdata;
    return ins;
  case INS_SH:
    *((short*)&(((char*)mem)[addr])) = (short)wdata;
    return ins;
  case INS_SW:
    *((int*)&(((char*)mem)[addr])) = (int)wdata;
    return ins;
  case INS_LB:
    return *((signed char*)&(((char*)mem)[addr]));
  case INS_LBU:
    return *((unsigned char*)&(((char*)mem)[addr]));
  case INS_LH:
    return *((signed short*)&(((char*)mem)[addr]));
  case INS_LHU:
    return *((unsigned short*)&(((char*)mem)[addr]));
  case INS_LW:
    return *((signed int*)&(((char*)mem)[addr]));
  default:
    return ins;
  }
}

int
execute_step(int * pc, int int_reg[32], void * imem, void * dmem)
{
  /* instruction fetch */
  int imem_rdata;
  imem_rdata = ((int *)imem)[(*pc) >> 2];

  /* instruction decode */
  ins_t ins;
  alu_op_t alu_op;
  imm_type_t imm_type;
  int imm;
  int rd_wen;
  rd_src_t rd_src;
  jump_cond_t jump_cond;

  ins = decode_ins(imem_rdata);
  if (ins == INS_ILLEGAL)
    return -1; // illegal instruction

  imm_type = control_imm_type(ins);
  alu_op = control_alu_op(ins);

  if (imm_type >= 0)
    imm = decode_imm(imm_type, imem_rdata);

  rd_wen = control_rd_wen(ins);
  if (rd_wen)
    rd_src = control_rd_src(ins);

  jump_cond = control_jump_cond(ins);

  /* register fetch */
  int rs1;
  int rs2;
  int rs1_rdata;
  int rs2_rdata;

  rs1 = (imem_rdata >> 15) & 31;
  rs2 = (imem_rdata >> 20) & 31;
  rs1_rdata = rs1 == 0 ? 0 : int_reg[rs1];
  rs2_rdata = rs2 == 0 ? 0 : int_reg[rs2];

  /* execute */
  int alu_a;
  int alu_b;
  int alu_y;

  alu_a = ((ins == INS_LUI) ? 0 :
           (ins == INS_AUIPC) ? *pc :
           rs1_rdata);
  alu_b = ((imm_type != IMM_NONE && imm_type != IMM_B) ? imm : rs2_rdata);

  alu_y = alu_execute(alu_op, alu_a, alu_b);

  /* memory */
  int dmem_rdata;

  dmem_rdata = execute_dmem(ins, rs2_rdata, dmem, alu_y);

  /* commit */
  int pc_4;
  int rd_wdata;

  pc_4 = *pc + 4;

  if (rd_wen) {
    int rd = (imem_rdata >> 7) & 31;
    switch (rd_src) {
    case RD_SRC_ALU_Y:
      rd_wdata = alu_y;
      break;
    case RD_SRC_DMEM_RDATA:
      rd_wdata = dmem_rdata;
      break;
    case RD_SRC_PC_4:
      rd_wdata = pc_4;
      break;
    default:
      rd_wdata = -1;
      break;
    }
    if (rd != 0)
      int_reg[rd] = rd_wdata;
  }

  /* next pc */
  int jump_base = (ins == INS_JALR) ? rs1_rdata : *pc;
  int jump_target = jump_base + imm;

  switch (jump_cond) {
  case JUMP_COND_NEVER:
    *pc = pc_4;
    break;
  case JUMP_COND_ALWAYS:
    *pc = jump_target;
    break;
  case JUMP_COND_ZERO:
    if (alu_y == 0)
      *pc = jump_target;
    else
      *pc = pc_4;
    break;
  case JUMP_COND_ONE:
    if (alu_y == 1)
      *pc = jump_target;
    else
      *pc = pc_4;
    break;
  }

  return 0;
}
