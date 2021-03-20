`include "control.vh"

module branch_predict
( input  [31:0] pc
, input  [31:0] ins
// output
, output [31:0] target
, output        taken
);
   wire sign = ins[31];

   wire op_32 = (ins[1:0] == 2'b11);
   wire op_branch = (op_32 && ins[6:2] == `OP_BRANCH);
   wire op_jal = (op_32 && ins[6:2] == `OP_JAL);

   wire [31:0] imm_j_type = {{12{ins[31]}}, ins[19:12], ins[20], ins[30:25], ins[24:21], 1'b0};
   wire [31:0] imm_b_type = {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};

   wire [31:0] offset = op_branch ? imm_b_type : imm_j_type;

   assign target = pc + offset;
   /* predict branch-taken for BRANCH instructions with negative offsets */
   assign taken = (op_jal || (sign && op_branch));

endmodule
