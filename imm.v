`include "include.v"

// 44 LC
module imm_gen
  (
   input [2:0]       imm_type,
   input [31:7]      ins_i,
   output reg [31:0] imm
   );

   always @* begin
      case (imm_type)
        `IMM_I_TYPE:
          imm = {{21{ins_i[31]}}, ins_i[30:25], ins_i[24:21], ins_i[20]};
        `IMM_S_TYPE:
          imm = {{21{ins_i[31]}}, ins_i[30:25], ins_i[11:8], ins_i[7]};
        `IMM_B_TYPE:
          imm = {{20{ins_i[31]}}, ins_i[7], ins_i[30:25], ins_i[11:8], 1'b0};
        `IMM_U_TYPE:
          imm = {ins_i[31], ins_i[30:20], ins_i[19:12], 12'b0};
        `IMM_J_TYPE:
          imm = {{12{ins_i[31]}}, ins_i[19:12], ins_i[20], ins_i[30:25], ins_i[24:21], 1'b0};
        default:
          imm = {32{1'b1}};
      endcase
   end
endmodule


module imm_ins
  (
   input [6:0]      op_code,
   output reg [2:0] imm_type
   );

   wire [4:0]  base;
   assign base = op_code[6:2];

   always @* begin
      case (base)
        `INS_LOAD: imm_type = `IMM_I_TYPE;
        `INS_STORE: imm_type = `IMM_S_TYPE;
        `INS_BRANCH: imm_type = `IMM_B_TYPE;
        `INS_AUIPC: imm_type = `IMM_U_TYPE;
        `INS_LUI: imm_type = `IMM_U_TYPE;
        `INS_OP_IMM: imm_type = `IMM_I_TYPE;
        //`INS_OP: imm_type = `IMM_R_TYPE;
        `INS_JALR: imm_type = `IMM_I_TYPE;
        `INS_JAL: imm_type = `IMM_J_TYPE;
        //`INS_SYSTEM: imm_type = `IMM_I_TYPE;
        default: imm_type = 3'b0;
      endcase
   end
endmodule
