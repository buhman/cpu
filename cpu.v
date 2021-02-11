`include "include.v"

module cpu
  (
   input             clk,
   output [31:0]     imem_addr,
   input [31:0]      imem_data,
   output reg [31:0] alu_out,
   output [6:0]      leds_out
   );

   // reset

   reg          reset = 1;
   reg          halt;

   reg [31:0]        pc;
   wire [31:0]       pc_nxt;
   reg [31:0]        pc_incr;

   always @(pc_imm[0]) begin
      pc_incr = pc_imm[0] && pc_imm[1] == alu_zero ? imm : 4;

      if (pc_imm[0])
        $display("branch %h %h %h take:%d", imem_data, imm, imm+pc, alu_zero == pc_imm[1]);
   end

   assign pc_nxt = pc + pc_incr;
   assign imem_addr = pc_nxt;

   assign leds_out[0] = reset;
   assign leds_out[6:1] = pc[6:0];

   always @(posedge clk) begin
      if (reset) begin
         pc <= -4;
         reset <= 0;
         halt <= 0;
      end else begin
        pc <= pc_nxt;
      end
   end

   //

   wire [6:0]  op_code;
   assign op_code = imem_data[6:0];

   // imm

   wire [2:0]  imm_type;

   imm_ins ii (.op_code(op_code),
               .imm_type(imm_type)
               );

   wire [31:7] ins_i;
   assign ins_i[31:7] = imem_data[31:7];
   wire [31:0] imm;

   imm_gen ig (.imm_type(imm_type),
               .ins_i(ins_i),
               .imm(imm)
               );

   //

   wire [2:0]  funct3;
   wire [6:0]  funct7;
   assign funct3 = imem_data[14:12];
   assign funct7 = imem_data[31:25];
   wire        op_illegal;
   wire        alu_imm;
   wire [2:0]  alu_op;
   wire        alu_alt;
   wire        reg_wen;
   wire [1:0]  pc_imm;

   control c (.op_code(op_code),
              .funct3(funct3),
              .funct7(funct7),
              .op_illegal(op_illegal),
              .alu_imm(alu_imm),
              .alu_op(alu_op),
              .alu_alt(alu_alt),
              .reg_wen(reg_wen),
              .pc_imm(pc_imm)
              );

   // regs

   wire [4:0] rd_addr = imem_data[11:7];
   wire [4:0] rs1_addr = imem_data[19:15];
   wire [4:0] rs2_addr = imem_data[24:20];

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

   always @(posedge clk)
     $display("%t clk:%d wen:%d rs1:%d rs2:%d rd:%d %h %h %h", $time, clk, reg_wen, rs1_addr, rs2_addr, rd_addr, pc, pc_nxt, imem_data);

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

   always @(posedge clk) begin
      //$display("pc %h idata %h pc_nxt %h", pc, imem_data, pc_nxt);
      //$display("regs wen:%d rd:%d rs1:%d rs2:%d", reg_wen, rd_addr, rs1_addr, rs2_addr);
   end

   assign rd_wdata = alu_y;

   always @(negedge clk) begin
      //$display("alu %b %b a:%d b:%d y:%d", alu_op, alu_alt, alu_a, alu_b, alu_y);
      alu_out <= alu_y;
   end

endmodule
