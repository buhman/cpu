`include "include.v"

module control
  (
   input            clk,
   input [6:0]      op_code,
   input [2:0]      funct3,
   input [6:0]      funct7,
   output wire      op_illegal,
   output reg       alu_imm,
   output reg [2:0] alu_op,
   output reg       alu_alt,
   output reg       reg_wen,
   output reg [1:0] pc_imm = 0
   );

   wire [4:0]  base;
   reg         base_illegal;

   assign base = op_code[6:2];
   assign op_illegal = ((op_code[1:0] != 2'b11) | base_illegal);

   always @* begin
      case (base)
        `INS_OP_IMM: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = funct3;
           alu_alt = funct7[5];
           reg_wen = 1;
           pc_imm = 2'b0;
        end
        `INS_OP: begin
           base_illegal = 0;
           alu_imm = 0;
           alu_op = funct3;
           alu_alt = funct7[5];
           reg_wen = 1;
           pc_imm = 2'b0;
        end
        `INS_BRANCH: begin
           base_illegal = 0;
           alu_imm = 0;
           reg_wen = 0;
           case (funct3)
             `FUNCT3_BEQ: begin
                alu_op = `ALU_ADD;
                alu_alt = 1;
                pc_imm = 2'b11; // (is zero)
             end
             `FUNCT3_BNE: begin
                alu_op = `ALU_ADD;
                alu_alt = 1;
                pc_imm = 2'b01; // (is not zero)
             end
             `FUNCT3_BLT: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = 2'b11; // (is one)
             end
             `FUNCT3_BGE: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = 2'b11; // (is not one)
             end
             `FUNCT3_BLTU: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = 2'b01; // (is one)
             end
             `FUNCT3_BGEU: begin
                alu_op = `ALU_SLTU;
                alu_alt = 0;
                pc_imm = 2'b11; // (is not one)
             end
             default: begin // invalid instruction
                alu_op = `ALU_ADD;
                alu_alt = 0;
                pc_imm = 2'b0;
             end
           endcase
        end
        default: begin
           base_illegal = 1;
           alu_imm = 0;
           alu_op = 0;
           alu_alt = 0;
           reg_wen = 0;
           pc_imm = 2'b0;
        end
      endcase
   end

endmodule
