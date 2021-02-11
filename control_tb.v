`include "include.v"

module control_tb;
   reg [6:0] op_code;

   wire      alu_imm;
   wire      op_illegal;

   control c (.op_code(op_code),
              .alu_imm(alu_imm),
              .op_illegal(op_illegal)
              );

   initial begin
      #1 op_code = 7'b0000000;
      #1 op_code = 7'b0010011;
      #1 op_code = 7'b0110011;
      #1 op_code = 7'b0110111;
   end

   initial
     $monitor("%t op:%b ai:%b oi:%b", $time, op_code, alu_imm, op_illegal);

endmodule
