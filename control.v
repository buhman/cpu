`include "control.vh"
`include "dmem_encdec.vh"
`include "execute.vh"
`include "jump.vh"
`include "writeback.vh"
`include "int_alu.vh"

(* nolatches *)
module control
( input  [31:0] ins
// output
, output        ins_illegal
, output reg [31:0] imm
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
, output  [4:0] rd_addr

, output [11:0] csr_addr
, output  [1:0] csr_op
, output        csr_src

, output        ecall
, output        ebreak

, output        trap_return
);
   wire  [6:0] op_code = ins[6:0];
   wire  [2:0] funct3  = ins[14:12];
   wire  [6:0] funct7  = ins[31:25];
   wire [11:0] funct12 = ins[31:20];
   assign      rd_addr = ins[11:7];
   assign     rs1_addr = ins[19:15];
   assign     rs2_addr = ins[24:20];
   assign     csr_addr = funct12;

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

   /* rv32i instruction decode */
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

   wire environment = (op_system && rd_addr == 5'b00000 && funct3 == 3'b000 && rs1_addr == 5'd00000);
   wire ins_ecall  = (environment && funct12 == `FUNCT12_ECALL);
   wire ins_ebreak = (environment && funct12 == `FUNCT12_EBREAK);

   /* Zicsr instruction decode */
   wire ins_csrrw = (op_system && funct3 == `FUNCT3_CSRRW);
   wire ins_csrrs = (op_system && funct3 == `FUNCT3_CSRRS);
   wire ins_csrrc = (op_system && funct3 == `FUNCT3_CSRRC);
   wire ins_csrrwi = (op_system && funct3 == `FUNCT3_CSRRWI);
   wire ins_csrrsi = (op_system && funct3 == `FUNCT3_CSRRSI);
   wire ins_csrrci = (op_system && funct3 == `FUNCT3_CSRRCI);

   wire ins__csr = ( ins_csrrw  || ins_csrrs  || ins_csrrc
                  || ins_csrrwi || ins_csrrsi || ins_csrrci );

   /* trap return decode */
   wire op_trap_return = (op_system && rd_addr == 5'b00000 && funct3 == 3'b000 && rs1_addr == 5'b00000 && rs2_addr == 5'b00010);
   wire ins_mret = (op_trap_return && funct7 == `FUNCT7_MRET);

   assign ins_illegal =
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

        || ins__csr

        || ins_mret
        );

   /* immediate decode */
   wire [2:0] imm_type = (op_lui || op_auipc)              ? `IMM_U_TYPE :
                         (op_jal)                          ? `IMM_J_TYPE :
                         (op_jalr || op_load || op_op_imm) ? `IMM_I_TYPE :
                         (op_branch)                       ? `IMM_B_TYPE :
                         (op_store)                        ? `IMM_S_TYPE :
                         (ins_csrrwi || ins_csrrsi || ins_csrrci) ? `IMM_UIMM_RS1 :
                         `IMM_NONE_TYPE;

   // jal and jalr store pc_4; the immediate is added to the base address in a
   // separate adder
   //
   // branch does not store; the immediate is added in a separate adder
   wire   alu_immediate = ( op_lui || op_auipc
                         || op_load || op_store
                         || op_op_imm );

   wire [31:0] imm_i_type = {{21{ins[31]}}, ins[30:25], ins[24:21], ins[20]};
   wire [31:0] imm_s_type = {{21{ins[31]}}, ins[30:25], ins[11:8], ins[7]};
   wire [31:0] imm_b_type = {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};
   wire [31:0] imm_u_type = {ins[31], ins[30:20], ins[19:12], 12'b0};
   wire [31:0] imm_j_type = {{12{ins[31]}}, ins[19:12], ins[20], ins[30:25], ins[24:21], 1'b0};
   wire [31:0] imm_uimm_rs1 = {{27{1'b0}}, rs1_addr};

   (* always_comb *)
   always @*
     case (imm_type)
       `IMM_I_TYPE: imm = imm_i_type;
       `IMM_S_TYPE: imm = imm_s_type;
       `IMM_B_TYPE: imm = imm_b_type;
       `IMM_U_TYPE: imm = imm_u_type;
       `IMM_J_TYPE: imm = imm_j_type;
       `IMM_UIMM_RS1: imm = imm_uimm_rs1;
       default: imm = 32'hffffffff;
     endcase

   /* alu decode */
   wire alu_add = ins_lui || ins_auipc || ins_jal || ins_jalr || op_load || op_store || ins_addi || ins_add;
   wire alu_sub = ins_sub;
   wire alu_sll = ins_slli || ins_sll;
   wire alu_srl = ins_srli || ins_srl;
   wire alu_sra = ins_srai || ins_sra;
   wire alu_lt  = ins_blt  || ins_bge  || ins_slti  || ins_slt;
   wire alu_ltu = ins_bltu || ins_bgeu || ins_sltiu || ins_sltu;
   wire alu_xor = ins_xori || ins_xor;
   wire alu_or  = ins_ori  || ins_or;
   wire alu_and = ins_andi || ins_and;
   wire alu_eq  = ins_beq || ins_bne;

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
                   alu_eq  ? `ALU_EQ  :
                   0;

   assign alu_a_src = op_lui   ? `ALU_A_ZERO : // bypass instead?
                      op_auipc ? `ALU_A_PC   :
                      `ALU_A_RS1;

   assign alu_b_src = alu_immediate ? `ALU_B_IMM : `ALU_B_RS2;

   /* environment control decode */

   assign ecall = ins_ecall;
   assign ebreak = ins_ebreak;

   /* dmem control decode */

   assign dmem_width = (ins_lb || ins_lbu || ins_sb) ? `ENCDEC_BYTE :
                       (ins_lh || ins_lhu || ins_sh) ? `ENCDEC_HALF :
                       (ins_lw || ins_sw)            ? `ENCDEC_WORD :
                       `ENCDEC_ZERO;

   assign dmem_zero_ext = (ins_lbu || ins_lhu);
   assign dmem_read = op_load;
   assign dmem_write = op_store;

   /* jump control decode */
   assign jump_base_src = ins_jalr ? `BASE_SRC_RS1 : `BASE_SRC_PC;

   assign jump_cond = (ins_jal || ins_jalr)            ? `COND_ALWAYS :
                      (ins_bne || ins_bge || ins_bgeu) ? `COND_ZERO   :
                      (ins_beq || ins_blt || ins_bltu) ? `COND_ONE    :
                      `COND_NEVER;

   /* int reg control decode */
   assign rd_wen = ( op_lui  || op_auipc  || op_jal || op_jalr
                  || op_load || op_op_imm || op_op
                  || ins__csr );

   assign rd_src = op_load             ? `RD_SRC_DMEM_RDATA :
                   (op_jal || op_jalr) ? `RD_SRC_PC_4 :
                   ins__csr            ? `RD_SRC_CSR :
                   `RD_SRC_ALU_Y;

   /* csr reg control decode */

   assign csr_op = (ins_csrrw || ins_csrrwi) ? `CSR_WRITE :
                   (ins_csrrs || ins_csrrsi) ? `CSR_SET   :
                   (ins_csrrc || ins_csrrci) ? `CSR_CLEAR :
                   `CSR_NOP;

   assign csr_src = (ins_csrrwi || ins_csrrsi || ins_csrrci) ? `CSR_SRC_UIMM_RS1 :
                    `CSR_SRC_RS1;

   /* trap return control decode */

   assign trap_return = ins_mret;

endmodule
