`include "int_alu.vh"

(* nolatches *)
module int_alu
(
  input      [ 3:0] op
, input      [31:0] a
, input      [31:0] b
, output reg [31:0] y
);
   wire [31:0]   add = a + b;
   wire [31:0]   sub = $signed(a) - $signed(b);
   wire           lt = $signed(a) < $signed(b);
   wire          ltu = a < b;

   wire [31:0] b_xor = a ^ b;
   wire [31:0] b_or  = a | b;
   wire [31:0] b_and = a & b;

   wire  [4:0] shamt = b[4:0];
   wire   [31:0] sll = a << shamt;
   wire   [31:0] srl = a >> shamt;
   wire   [31:0] sra = $signed(a) >>> $signed(shamt);

   wire           eq = a == b;

   wire [30:0] zero_fill = 31'd0;

   (* always_comb *)
   always @*
     case (op)
       `ALU_ADD           : y = add;
       `ALU_SUB           : y = sub;
       `ALU_SLL           : y = sll;
       `ALU_SRL           : y = srl;
       `ALU_SRA           : y = sra;
       `ALU_LT            : y = {zero_fill, lt};
       `ALU_LTU           : y = {zero_fill, ltu};
       `ALU_XOR           : y = b_xor;
       `ALU_OR            : y = b_or;
       `ALU_AND           : y = b_and;
       `ALU_EQ            : y = {zero_fill, eq};
       default            : y = 32'd0;
     endcase

endmodule
