`include "include.v"

module cpu
  (
   input         clk,
   output [31:0] imem_addr,
   input [31:0]  imem_data,
   output [3:0]  dmem_writeb,
   output        dmem_read,
   output [31:0] dmem_addr,
   input [31:0]  dmem_rdata,
   output [31:0] dmem_wdata,
   output [31:0] pc_out
   );

   // reset

   always @(reset)
     $display("%t reset %d", $time, reset);

   reg          reset = 1;
   reg [31:0]   pc = -4;
   wire [31:0]  pc_nxt;
   reg [31:0]   pc_incr;

   assign pc_out = pc;

   always @* begin
      case (pc_imm)
        `PC_IMM_0: pc_incr = 0;
        `PC_IMM_4: pc_incr = 4;
        `PC_IMM_BNZ: pc_incr = !alu_zero ? imm : 4;
        `PC_IMM_BZ: pc_incr = alu_zero ? imm : 4;
        `PC_IMM_JAL: pc_incr = imm;
        `PC_IMM_JALR: pc_incr = imm + rs1_rdata;
      endcase
   end

   assign pc_nxt = (pc_imm == `PC_IMM_JALR) ? pc_incr : pc + pc_incr;
   assign imem_addr = pc_nxt;

   always @(posedge clk) begin
      if (reset) reset <= 0;

      pc <= pc_nxt;
   end

   // decode

   wire [31:0]  ins;
   assign ins = reset
                ? 32'h00000013 // addi x0,x0,0
                : imem_data;

   wire [6:0]  op_code = ins[6:0];
   wire [31:7] ins_i = ins[31:7];
   wire [2:0]  funct3 = ins[14:12];
   wire [6:0]  funct7 = ins[31:25];
   wire [4:0]  rd_addr = ins[11:7];
   wire [4:0]  rs1_addr = ins[19:15];
   wire [4:0]  rs2_addr = ins[24:20];

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
   wire        alu_mul;
   wire        reg_wen;
   wire [2:0]  pc_imm;
   wire        dmem_reg;
   wire        alu_a0;
   wire        alu_apc;
   wire        alu_b4;
   wire        dmem_write;

   control c (.clk(clk),
              .reset(reset),
              .op_code(op_code),
              .funct3(funct3),
              .funct7(funct7),
              .op_illegal(op_illegal),
              .alu_imm(alu_imm),
              .alu_op(alu_op),
              .alu_alt(alu_alt),
              .alu_mul(alu_mul),
              .reg_wen(reg_wen),
              .pc_imm(pc_imm),
              .dmem_write(dmem_write),
              .dmem_read(dmem_read),
              .dmem_reg(dmem_reg),
              .alu_a0(alu_a0),
              .alu_apc(alu_apc),
              .alu_b4(alu_b4)
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
   assign alu_a = (alu_a0) ? 0 : (alu_apc) ? pc : rs1_rdata;
   assign alu_b = (alu_b4) ? 4 : (alu_imm) ? imm : rs2_rdata;

   int_alu ia (.op(alu_op),
               .alt(alu_alt),
               .a(alu_a),
               .b(alu_b),
               .y(alu_y),
               .zero(alu_zero)
               );

`ifdef ENABLE_MUL
   wire [31:0] alu_mul_y;
   mul_alu ma (.op(alu_op),
               .a(alu_a),
               .b(alu_b),
               .y(alu_mul_y)
               );
`endif

   // dmem

   wire [31:0] dmem_decode;
   wire        dmem_unaligned;
   word_encdec wed (.funct3(funct3),
                    .addr(dmem_addr[1:0]),
                    .data(dmem_rdata),
                    .decode(dmem_decode),
                    .unaligned(dmem_unaligned),
                    .write(dmem_write),
                    .writeb(dmem_writeb)
                    );

   assign dmem_addr = alu_y;
   assign dmem_wdata = rs2_rdata;
   assign rd_wdata = dmem_reg ? dmem_decode :
`ifdef ENABLE_MUL
                     alu_mul ? alu_mul_y :
`endif
                     alu_y;

   // simulation

   always @(posedge clk) begin
      if (alu_mul)
        $display("%t funct7 %d", $time, alu_mul);
      $display("%t wen:%d rs1:%d/%h rs2:%d/%h rd:%d/%h %h %h", $time, reg_wen, rs1_addr, rs1_rdata, rs2_addr, rs2_rdata, rd_addr, rd_wdata, pc, ins);
      //$display("%t %h %h", $time, pc, ins);
   end

endmodule
