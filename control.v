`include "include.v"

module control
  (
   input            clk,
   input            reset,
   input [6:0]      op_code,
   input [2:0]      funct3,
   input [6:0]      funct7,
   output           op_illegal,
   output reg       alu_imm,
   output reg [2:0] alu_op,
   output reg       alu_alt,
   output           alu_mul,
   output reg       reg_wen,
   output reg [2:0] pc_imm,
   output           dmem_write,
   output           dmem_read,
   output           dmem_reg,
   output           alu_a0,
   output           alu_apc,
   output           alu_b4
   );

   wire [4:0]  base;
   reg         base_illegal;

   reg         stage = 0;
   // set the state for the next cycle
   always @(posedge clk) begin
      //$display("%t control %b stage %b", $time, op_code, stage);
      if (reset) stage <= 0;
      else
        case (base)
          `INS_LOAD: stage <= stage + 1;
          default: stage <= 0;
        endcase
      if (stage > 0)
        $display("%t stage %d", $time, stage);
   end

   assign base = op_code[6:2];
   assign op_illegal = ((op_code[1:0] != 2'b11) | base_illegal);

   wire is_load;
   assign is_load = (base == `INS_LOAD);
   assign dmem_reg = (stage == 1 && is_load);
   assign dmem_read = (stage == 0 && is_load);
   assign dmem_write = (base == `INS_STORE);

   assign alu_a0 = (base == `INS_LUI);
   assign alu_apc = (base == `INS_AUIPC || base == `INS_JAL || base == `INS_JALR);
   assign alu_b4 = (base == `INS_JAL || base == `INS_JALR);
   assign alu_mul = (funct7 == 7'b1 && base == `INS_OP);

   always @* begin
      case (base)
        `INS_OP_IMM: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = funct3;
           alu_alt = 0;
           reg_wen = 1;
           pc_imm = `PC_IMM_4;
        end
        `INS_OP: begin
           base_illegal = 0;
           alu_imm = 0;
           alu_op = funct3;
           alu_alt = funct7[5];
           reg_wen = 1;
           pc_imm = `PC_IMM_4;
        end
        `INS_BRANCH: begin
           base_illegal = !(funct3 == `FUNCT3_BEQ ||
                            funct3 == `FUNCT3_BNE ||
                            funct3 == `FUNCT3_BLT ||
                            funct3 == `FUNCT3_BGE ||
                            funct3 == `FUNCT3_BLTU ||
                            funct3 == `FUNCT3_BGEU);
           alu_imm = 0;
           reg_wen = 0;
           case (funct3)
             `FUNCT3_BEQ: begin
                alu_op = `ALU_ADD;
                alu_alt = 1;
                pc_imm = `PC_IMM_BZ; // (rs1 - rs2 == 0)
             end
             `FUNCT3_BNE: begin
                alu_op = `ALU_ADD;
                alu_alt = 1;
                pc_imm = `PC_IMM_BNZ; // (rs1 - rs2 != 0)
             end
             `FUNCT3_BLT: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = `PC_IMM_BNZ; // (rs1 < rs2 != 0)
             end
             `FUNCT3_BGE: begin
                alu_op = `ALU_SLT;
                alu_alt = 0;
                pc_imm = `PC_IMM_BZ; // (rs1 < rs2 == 0)
             end
             `FUNCT3_BLTU: begin
                alu_op = `ALU_SLTU;
                alu_alt = 0;
                pc_imm = `PC_IMM_BNZ; // (rs1 < rs2 != 0)
             end
             `FUNCT3_BGEU: begin
                alu_op = `ALU_SLTU;
                alu_alt = 0;
                pc_imm = `PC_IMM_BZ; // (rs1 < rs2 == 0)
             end
             default: begin // invalid instruction
                alu_op = `ALU_ADD;
                alu_alt = 0;
                pc_imm = `PC_IMM_0;
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
           pc_imm = (base == `INS_JAL
                     ? `PC_IMM_JAL
                     : `PC_IMM_JALR); // always jump
        end
        `INS_LOAD: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = `ALU_ADD;
           alu_alt = 0;
           case (stage)
             0: reg_wen = 0;
             1: reg_wen = 1;
           endcase
           pc_imm = (stage ? `PC_IMM_4 : `PC_IMM_0);
        end
        `INS_STORE: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = `ALU_ADD;
           alu_alt = 0;
           reg_wen = 0;
           pc_imm = `PC_IMM_4;
        end
        `INS_LUI,
        `INS_AUIPC: begin
           base_illegal = 0;
           alu_imm = 1;
           alu_op = `ALU_ADD;
           alu_alt = 0;
           reg_wen = 1;
           pc_imm = `PC_IMM_4;
        end
        default: begin
           base_illegal = 1;
           alu_imm = 0;
           alu_op = 0;
           alu_alt = 0;
           reg_wen = 0;
           pc_imm = `PC_IMM_0;
        end
      endcase
   end
endmodule
