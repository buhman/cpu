`include "jump.vh"

(* nolatches *)
module jump
( input  [31:0] pc
, input  [31:0] imm
, input  [31:0] rs1_rdata
, input         alu_zero
, input         base_src
, input   [1:0] cond
, output [31:0] target
, output reg    taken
);
   /*
    the branch instructions use the ALU for sub/lt/ltu on (rs1, rs2)

    the branch unit requires a separate adder
    */

   wire [31:0] base = (base_src == `BASE_SRC_RS1) ? rs1_rdata : pc;

   assign target = base + imm;

   (* always_comb *)
   always @*
     case (cond)
       `COND_NEVER:    taken = 1'b0;
       `COND_ALWAYS:   taken = 1'b1;
       `COND_EQ_ZERO:  taken = alu_zero;
       `COND_NEQ_ZERO: taken = !alu_zero;
     endcase

endmodule
