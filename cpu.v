`include "include.v"

module cpu
  (
   input             clk,
   output [31:0]     imem_addr,
   input [31:0]      imem_data,
   output            dmem_write,
   output            dmem_read,
   output [31:0]     dmem_addr,
   input [31:0]      dmem_rdata,
   output [31:0]     dmem_wdata,
   );

   // reset

   reg          reset = 1;
   reg [31:0]   pc;
   wire [31:0]  pc_nxt;
   wire [31:0]  pc_incr;

   assign pc_incr = pc_imm[0] && pc_imm[1] == alu_zero ? imm : 4;

   /*
   always @(pc_incr)
     if (pc_imm[0])
       $display("%t branch %h %h %h take:%d pc_incr:%d", $time, imem_data, imm, imm+pc, alu_zero == pc_imm[1], pc_incr);
    */

   assign pc_nxt = pc + pc_incr;
   assign imem_addr = pc_nxt;

   always @(posedge clk) begin
      if (reset) begin
         pc <= -4;
         reset <= 0;
      end else
         pc <= pc_nxt;
   end

   // decode

   wire [6:0]  op_code = imem_data[6:0];
   wire [31:7] ins_i = imem_data[31:7];
   wire [2:0]  funct3 = imem_data[14:12];
   wire [6:0]  funct7 = imem_data[31:25];
   wire [4:0]  rd_addr = imem_data[11:7];
   wire [4:0]  rs1_addr = imem_data[19:15];
   wire [4:0]  rs2_addr = imem_data[24:20];

   // imm

   wire [2:0]  imm_type;

   imm_ins ii (.op_code(op_code),
               .imm_type(imm_type)
               );

   wire [31:0] imm;

   imm_gen ig (.imm_type(imm_type),
               .ins_i(ins_i),
               .imm(imm)
               );

   // control

   wire        op_illegal;
   wire        alu_imm;
   wire [2:0]  alu_op;
   wire        alu_alt;
   wire        reg_wen;
   wire [1:0]  pc_imm;
   wire        dmem_reg;

   control c (.op_code(op_code),
              .funct3(funct3),
              .funct7(funct7),
              .op_illegal(op_illegal),
              .alu_imm(alu_imm),
              .alu_op(alu_op),
              .alu_alt(alu_alt),
              .reg_wen(reg_wen),
              .pc_imm(pc_imm),
              .dmem_write(dmem_write),
              .dmem_read(dmem_read),
              .dmem_reg(dmem_reg)
              );

   // regs

   wire [31:0] rd_wdata;
   wire [31:0] rs1_rdata;
   wire [31:0] rs2_rdata;

   int_regs ir (.clk(clk),
                .wen(reg_wen),
                .rd_addr(rd_addr),
                .rs1_addr(rs1_addr),
                .rs2_addr(rs2_addr),
                .rd_wdata(rd_wdata),
                .rs1_rdata(rs1_rdata),
                .rs2_rdata(rs2_rdata)
                );

   // alu

   wire [31:0] alu_a;
   wire [31:0] alu_b;
   wire [31:0] alu_y;
   wire        alu_zero;
   assign alu_a = rs1_rdata;
   assign alu_b = (alu_imm) ? imm : rs2_rdata;

   int_alu ia (.op(alu_op),
               .alt(alu_alt),
               .a(alu_a),
               .b(alu_b),
               .y(alu_y),
               .zero(alu_zero)
               );

   // dmem

   assign dmem_addr = alu_y;
   assign dmem_wdata = rs2_rdata;
   assign rd_wdata = dmem_reg ? dmem_rdata : alu_y;

   // simulation

   always @(posedge clk) begin
      //$display("%t wen:%d rs1:%d/%d rs2:%d/%d rd:%d/%d %h %h", $time, reg_wen, rs1_addr, rs1_rdata, rs2_addr, rs2_rdata, rd_addr, rd_wdata, pc, imem_data);
   end

endmodule
