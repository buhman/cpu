`include "include.v"

// 654 LC , 21.39ns
module int_alu
  (
   input [2:0]       op,
   input             alt,
   input [31:0]      a,
   input [31:0]      b,
   output reg [31:0] y,
   output            zero
   );

   assign zero = (y == 0);

   always @* begin
      case (op)
        `ALU_ADD:
          y = alt ? a - b : a + b;
        `ALU_SLL:
          y = a << b[4:0];
        `ALU_SLT:
          y = $signed(a) < $signed(b);
        `ALU_SLTU:
          y = a < b;
        `ALU_XOR:
          y = a ^ b;
        `ALU_SRL:
          // the Verilog >>> operator only performs an arithmetic shift if the
          // result type of the entire expression is signed
          y = alt ? $signed(a) >>> b[4:0] : $signed(a) >> b[4:0];
        `ALU_OR:
          y = a | b;
        `ALU_AND:
          y = a & b;
      endcase
   end
endmodule

// 1355 LC
module mul_alu
  (
   input [2:0] op,
   input [31:0] a,
   input [31:0] b,
   output reg [31:0] y
   );

   always @* begin
      case (op)
        `ALU_MUL: y = a * b;
        default: y = 32'b0;
      endcase
   end
endmodule
