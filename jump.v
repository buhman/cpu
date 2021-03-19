`include "jump.vh"

(* nolatches *)
module jump
( input  [31:0] pc
, input  [31:0] imm
, input  [31:0] rs1_rdata
, input         alu_zero
, input         base_src
, input   [1:0] cond
// trap control
, input         ins_illegal
, input         ins_misalign
, input         ecall
, input         ebreak
, input         store_misalign
, input         load_misalign
// output
, output [31:0] target
, output reg    taken
);
   /*
    the branch instructions use the ALU for sub/lt/ltu on (rs1, rs2)

    the branch unit requires a separate adder
    */

   wire [31:0] base = (base_src == `BASE_SRC_RS1) ? rs1_rdata : pc;

   assign target = base + imm;

   /* trap control */
   wire [4:0] trap_src = ins_illegal    ? `TRAP_INS_ILLEGAL    :
                         ins_misalign   ? `TRAP_INS_MISALIGN   :
                         ecall          ? `TRAP_M_ECALL        :
                         ebreak         ? `TRAP_BREAK          :
                         store_misalign ? `TRAP_STORE_MISALIGN :
                         load_misalign  ? `TRAP_LOAD_MISALIGN  :
                         5'b11111;
   wire trap = ( ins_illegal || ins_misalign
               || ecall || ebreak
               || store_misalign || load_misalign
               );

   (* always_comb *)
   always @*
     case (cond)
       `COND_NEVER:    taken = 1'b0;
       `COND_ALWAYS:   taken = 1'b1;
       `COND_EQ_ZERO:  taken = alu_zero;
       `COND_NEQ_ZERO: taken = !alu_zero;
     endcase

endmodule
