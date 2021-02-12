`include "include.v"

module control
  (
   input            clk,
   input [6:0]      op_code,
   input [2:0]      funct3,
   input [6:0]      funct7,
   output           op_illegal,
   output reg       alu_imm,
   output reg [2:0] alu_op,
   output reg       alu_alt,
   output reg       reg_wen,
   output reg [2:0] pc_imm = 0,
   output           dmem_write,
   output           dmem_read,
   output           dmem_reg,
   output           alu_a0,
   output           alu_apc,
   output           alu_b4
   );

   wire [4:0]  base;
   reg         base_illegal;

   assign base = op_code[6:2];
   assign op_illegal = ((op_code[1:0] != 2'b11) | base_illegal);

   assign dmem_reg = dmem_read;
   assign dmem_read = (base == `INS_LOAD);
   assign dmem_write = (base == `INS_STORE);

   assign alu_a0 = (base == `INS_LUI);
   assign alu_apc = (base == `INS_AUIPC || base == `INS_JAL || base == `INS_JALR);
   assign alu_b4 = (base == `INS_JAL || base == `INS_JALR);

   always @* begin
      case (base)
        `INS_OP_IMM: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = funct3;
           alu_alt = 0;
           reg_wen = 1;
           pc_imm = 3'b0;
        end
        `INS_OP: begin
           base_illegal = 0;
           alu_imm = 0;
           alu_op = funct3;
           alu_alt = funct7[5];
           reg_wen = 1;
           pc_imm = 3'b0;
        end
        `INS_BRANCH: begin
           base_illegal = 0;
           alu_imm = 0;
           reg_wen = 0;
           case (funct3)
             `FUNCT3_BEQ: begin
                alu_op = `ALU_ADD;
                alu_alt = 1;
                pc_imm = 3'b11; // (is zero)
             end
             `FUNCT3_BNE: begin
                alu_op = `ALU_ADD;
                alu_alt = 1;
                pc_imm = 3'b01; // (is not zero)
             end
             `FUNCT3_BLT: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = 3'b11; // (is one)
             end
             `FUNCT3_BGE: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = 3'b11; // (is not one)
             end
             `FUNCT3_BLTU: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = 3'b01; // (is one)
             end
             `FUNCT3_BGEU: begin
                alu_op = `ALU_SLTU;
                alu_alt = 0;
                pc_imm = 3'b11; // (is not one)
             end
             default: begin // invalid instruction
                alu_op = `ALU_ADD;
                alu_alt = 0;
                pc_imm = 3'b0;
             end
           endcase
        end
        `INS_JAL,
        `INS_JALR: begin
           base_illegal = 0;
           alu_imm = 0;
           alu_op = `ALU_ADD;
           alu_alt = 0;
           reg_wen = 1;
           pc_imm = {1'b1, !(base[1]), 1'b1}; // always jump
        end
        `INS_LOAD,
        `INS_STORE: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = `ALU_ADD;
           alu_alt = 0;
           reg_wen = (base == `INS_LOAD);
           pc_imm = 3'b0;
        end
        `INS_LUI,
        `INS_AUIPC: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = `ALU_ADD;
           alu_alt = 0;
           reg_wen = 1;
           pc_imm = 3'b0;
        end
        default: begin
           base_illegal = 1;
           alu_imm = 0;
           alu_op = 0;
           alu_alt = 0;
           reg_wen = 0;
           pc_imm = 3'b0;
        end
      endcase
   end

endmodule
