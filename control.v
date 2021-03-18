`include "control.vh"
`include "dmem_encdec.vh"
`include "execute.vh"
`include "jump.vh"
`include "writeback.vh"
`include "int_alu.vh"

(* nolatches *)
module control
(
  input  [31:0] ins
, output reg [31:0] imm
, output  [4:0] rd_addr
, output  [4:0] rs1_addr
, output  [4:0] rs2_addr
, output  [3:0] alu_op
, output  [1:0] alu_a_src
, output        alu_b_src
, output  [1:0] dmem_width
, output        dmem_zero_ext
, output        dmem_read
, output        dmem_write
, output        jump_base_src
, output  [1:0] jump_cond
, output        rd_wen
, output  [1:0] rd_src
);
   wire  [6:0] op_code = ins[6:0];
   wire  [2:0] funct3  = ins[14:12];
   wire  [6:0] funct7  = ins[31:25];
   wire [11:0] funct12 = ins[31:20];
   assign      rd_addr = ins[11:7];
   assign     rs1_addr = ins[19:15];
   assign     rs2_addr = ins[24:20];

   wire        op_32 = (op_code[1:0] == 2'b11);
   wire [4:0]  op_base = op_code[6:2];

   /* opcode decode */
   wire op_load     = (op_32 && op_base == `OP_LOAD);
   wire op_store    = (op_32 && op_base == `OP_STORE);
   wire op_branch   = (op_32 && op_base == `OP_BRANCH);
   wire op_auipc    = (op_32 && op_base == `OP_AUIPC);
   wire op_lui      = (op_32 && op_base == `OP_LUI);
   wire op_op_imm   = (op_32 && op_base == `OP_OP_IMM);
   wire op_op       = (op_32 && op_base == `OP_OP);
   wire op_jalr     = (op_32 && op_base == `OP_JALR);
   wire op_jal      = (op_32 && op_base == `OP_JAL);
   wire op_system   = (op_32 && op_base == `OP_SYSTEM);
   wire op_misc_mem = (op_32 && op_base == `OP_MISC_MEM);

   /* instruction decode */
   wire ins_lui    = op_lui;
   wire ins_auipc  = op_auipc;
   wire ins_jal    = op_jal;
   wire ins_jalr   = op_jalr;

   wire ins_beq    = (op_branch && funct3 == `FUNCT3_BEQ);
   wire ins_bne    = (op_branch && funct3 == `FUNCT3_BNE);
   wire ins_blt    = (op_branch && funct3 == `FUNCT3_BLT);
   wire ins_bge    = (op_branch && funct3 == `FUNCT3_BGE);
   wire ins_bltu   = (op_branch && funct3 == `FUNCT3_BLTU);
   wire ins_bgeu   = (op_branch && funct3 == `FUNCT3_BGEU);

   wire ins_lb     = (op_load && funct3 == `FUNCT3_LB);
   wire ins_lh     = (op_load && funct3 == `FUNCT3_LH);
   wire ins_lw     = (op_load && funct3 == `FUNCT3_LW);
   wire ins_lbu    = (op_load && funct3 == `FUNCT3_LBU);
   wire ins_lhu    = (op_load && funct3 == `FUNCT3_LHU);

   wire ins_sb     = (op_store && funct3 == `FUNCT3_SB);
   wire ins_sh     = (op_store && funct3 == `FUNCT3_SH);
   wire ins_sw     = (op_store && funct3 == `FUNCT3_SW);

   wire ins_addi   = (op_op_imm && funct3 == `FUNCT3_ADD);
   wire ins_slti   = (op_op_imm && funct3 == `FUNCT3_SLT);
   wire ins_sltiu  = (op_op_imm && funct3 == `FUNCT3_SLTU);
   wire ins_xori   = (op_op_imm && funct3 == `FUNCT3_XOR);
   wire ins_ori    = (op_op_imm && funct3 == `FUNCT3_OR);
   wire ins_andi   = (op_op_imm && funct3 == `FUNCT3_AND);
   wire ins_slli   = (op_op_imm && funct3 == `FUNCT3_SLL && funct7 == `FUNCT7_ZERO);
   wire ins_srli   = (op_op_imm && funct3 == `FUNCT3_SRL && funct7 == `FUNCT7_ZERO);
   wire ins_srai   = (op_op_imm && funct3 == `FUNCT3_SRL && funct7 == `FUNCT7_ALT);

   wire ins_add    = (op_op && funct3 == `FUNCT3_ADD  && funct7 == `FUNCT7_ZERO);
   wire ins_sub    = (op_op && funct3 == `FUNCT3_ADD  && funct7 == `FUNCT7_ALT);
   wire ins_sll    = (op_op && funct3 == `FUNCT3_SLL  && funct7 == `FUNCT7_ZERO);
   wire ins_slt    = (op_op && funct3 == `FUNCT3_SLT  && funct7 == `FUNCT7_ZERO);
   wire ins_sltu   = (op_op && funct3 == `FUNCT3_SLTU && funct7 == `FUNCT7_ZERO);
   wire ins_xor    = (op_op && funct3 == `FUNCT3_XOR  && funct7 == `FUNCT7_ZERO);
   wire ins_srl    = (op_op && funct3 == `FUNCT3_SRL  && funct7 == `FUNCT7_ZERO);
   wire ins_sra    = (op_op && funct3 == `FUNCT3_SRL  && funct7 == `FUNCT7_ALT);
   wire ins_or     = (op_op && funct3 == `FUNCT3_OR   && funct7 == `FUNCT7_ZERO);
   wire ins_and    = (op_op && funct3 == `FUNCT3_AND  && funct7 == `FUNCT7_ZERO);

   wire ins_fence  = (op_misc_mem && funct3 == `FUNCT3_FENCE);

   wire ezero = (rd_addr == 5'b0 && funct3 == 3'b0 && rs1_addr == 5'b0);
   wire ins_ecall  = (op_system && ezero && funct12 == `FUNCT12_ECALL);
   wire ins_ebreak = (op_system && ezero && funct12 == `FUNCT12_EBREAK);

   wire ins_illegal =
        !( ins_lui || ins_auipc || ins_jal || ins_jalr

        || ins_beq || ins_bne || ins_blt || ins_bge
        || ins_bltu || ins_bgeu

        || ins_lb || ins_lh || ins_lw
        || ins_lbu || ins_lhu

        || ins_sb || ins_sh || ins_sw

        || ins_addi
        || ins_slti || ins_sltiu
        || ins_xori || ins_ori || ins_andi
        || ins_slli || ins_srli || ins_srai

        || ins_add || ins_sub
        || ins_sll || ins_slt || ins_sltu
        || ins_xor || ins_srl || ins_sra
        || ins_or  || ins_and

        || ins_fence

        || ins_ecall || ins_ebreak
        );

   /* immediate decode */
   wire [2:0] imm_type = (op_lui || op_auipc)              ? `IMM_U_TYPE :
                         (op_jal)                          ? `IMM_J_TYPE :
                         (op_jalr || op_load || op_op_imm) ? `IMM_I_TYPE :
                         (op_branch)                       ? `IMM_B_TYPE :
                         (op_store)                        ? `IMM_S_TYPE :
                         `IMM_NONE_TYPE;

   wire       immediate = ( op_lui || op_auipc
                         || op_jal || op_jalr
                         || op_load || op_store
                         || op_op_imm || op_branch );

   wire [31:0] imm_i_type = {{21{ins[31]}}, ins[30:25], ins[24:21], ins[20]};
   wire [31:0] imm_s_type = {{21{ins[31]}}, ins[30:25], ins[11:8], ins[7]};
   wire [31:0] imm_b_type = {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};
   wire [31:0] imm_u_type = {ins[31], ins[30:20], ins[19:12], 12'b0};
   wire [31:0] imm_j_type = {{12{ins[31]}}, ins[19:12], ins[20], ins[30:25], ins[24:21], 1'b0};

   (* always_comb *)
   always @*
     case (imm_type)
       `IMM_I_TYPE: imm = imm_i_type;
       `IMM_S_TYPE: imm = imm_s_type;
       `IMM_B_TYPE: imm = imm_b_type;
       `IMM_U_TYPE: imm = imm_u_type;
       `IMM_J_TYPE: imm = imm_j_type;
       default: imm = 32'hffffffff;
     endcase

   /* alu decode */
   wire alu_add = ins_lui || ins_auipc || ins_jal || ins_jalr || op_load || op_store || ins_addi || ins_add;
   wire alu_sub = ins_beq || ins_bne || ins_sub;
   wire alu_sll = ins_slli || ins_sll;
   wire alu_srl = ins_srli || ins_srl;
   wire alu_sra = ins_srai || ins_sra;
   wire alu_lt  = ins_blt  || ins_bge  || ins_slti  || ins_slt;
   wire alu_ltu = ins_bltu || ins_bgeu || ins_sltiu || ins_sltu;
   wire alu_xor = ins_xori || ins_xor;
   wire alu_or  = ins_ori  || ins_or;
   wire alu_and = ins_andi || ins_and;

   assign alu_op = alu_add ? `ALU_ADD :
                   alu_sub ? `ALU_SUB :
                   alu_sll ? `ALU_SLL :
                   alu_srl ? `ALU_SRL :
                   alu_sra ? `ALU_SRA :
                   alu_lt  ? `ALU_LT  :
                   alu_ltu ? `ALU_LTU :
                   alu_xor ? `ALU_XOR :
                   alu_or  ? `ALU_OR  :
                   alu_and ? `ALU_AND :
                   0;

   assign alu_a_src = op_lui   ? `ALU_A_ZERO : // bypass instead?
                      op_auipc ? `ALU_A_PC   :
                      `ALU_A_RS1;

   assign alu_b_src = immediate ? `ALU_B_IMM : `ALU_B_RS2;

   /* dmem control decode */

   assign dmem_width = (ins_lb || ins_lbu || ins_sb) ? `ENCDEC_BYTE :
                       (ins_lh || ins_lhu || ins_sh) ? `ENCDEC_HALF :
                       (ins_lw || ins_sw)            ? `ENCDEC_WORD :
                       `ENCDEC_ZERO;

   assign dmem_zero_ext = !(ins_lbu || ins_lhu);
   assign dmem_read = op_load;
   assign dmem_write = op_store;

   /* jump control decode */
   assign jump_base_src = ins_jalr ? `BASE_SRC_RS1 : `BASE_SRC_PC;

   assign jump_cond = (ins_jal || ins_jalr)            ? `COND_ALWAYS   :
                      (ins_beq || ins_bge || ins_bgeu) ? `COND_EQ_ZERO  :
                      (ins_bne || ins_blt || ins_bltu) ? `COND_NEQ_ZERO :
                      `COND_NEVER;

   /* reg control decode */
   assign rd_wen = ( op_lui  || op_auipc  || op_jal || op_jalr
                  || op_load || op_op_imm || op_op );

   assign rd_src = op_load             ? `RD_SRC_DMEM_RDATA :
                   (op_jal || op_jalr) ? `RD_SRC_PC_4 :
                   `RD_SRC_ALU_Y;

endmodule
