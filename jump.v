`include "jump.vh"

(* nolatches *)
module jump
( input         pipe_flush

, input  [31:0] pc
, input  [31:0] imm
, input  [31:0] rs1_rdata
, input         alu_y_lsb
, input         base_src
, input   [1:0] cond
// trap control
, input         external_int

, input         ins_illegal
, input         ecall
, input         ebreak
, input         store_misalign
, input         load_misalign
, input  [31:0] mtvec_rdata

, input         trap_return
, input  [31:0] mepc_rdata
// output
, output [31:0] jump_target
, output reg    branch_taken
, output        trap_taken
, output  [4:0] trap_src
);
   /*
    the branch instructions use the ALU for sub/lt/ltu on (rs1, rs2)

    the branch unit requires a separate adder
    */

   wire ins_misalign = target_misalign && branch_taken;

   /* trap control */
   assign trap_src = ins_illegal    ? `TRAP_INS_ILLEGAL    :
                     ins_misalign   ? `TRAP_INS_MISALIGN   :
                     ecall          ? `TRAP_M_ECALL        :
                     ebreak         ? `TRAP_BREAK          :
                     store_misalign ? `TRAP_STORE_MISALIGN :
                     load_misalign  ? `TRAP_LOAD_MISALIGN  :
                     external_int   ? `TRAP_M_EXT_INT   :
                     5'b11111;

   wire [31:0] trap_offset = {{26{1'b0}}, trap_src[3:0], 2'b00};

   wire trap = !pipe_flush &&
                ( ins_illegal || ins_misalign
               || ecall || ebreak
               || store_misalign || load_misalign
               || external_int);

   assign trap_taken = trap || trap_return;

   /* branch control */

   (* always_comb *)
   always @*
     case (cond)
       `COND_NEVER:  branch_taken = 1'b0;
       `COND_ALWAYS: branch_taken = 1'b1;
       `COND_ZERO:   branch_taken = !alu_y_lsb;
       `COND_ONE:    branch_taken = alu_y_lsb;
     endcase

   wire base_src_rs1 = (base_src == `BASE_SRC_RS1);

   /* jump control */

   wire [31:0] base = trap ? mtvec_rdata :
                      trap_return ? mepc_rdata :
                      base_src_rs1 ? rs1_rdata :
                      pc;

   wire [31:0] offset = trap ? trap_offset :
                        trap_return ? 32'h00000000 :
                        imm;

   /* assume trap_offset is aligned; the only other possibility is imm */
   wire target_misalign = imm[1:0] != 2'b00;
   assign jump_target = {base[31:2] + offset[31:2], 2'b00};

endmodule
