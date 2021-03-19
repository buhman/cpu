`include "jump.vh"

module cpu
( input clk
, output [31:0] pc
);
   assign pc = ex_mb__pc;

   wire pipe_flush;
   wire data_hazard;

   /* if -> id */
   wire [31:0] if_id__pc;
   wire [31:0] if_id__ins;

   /* id -> ex */
   wire [31:0] id_ex__rs1_rdata;
   wire [31:0] id_ex__rs2_rdata;
   wire  [4:0] id_ex__rs1_addr;
   wire  [4:0] id_ex__rs2_addr;
   wire [31:0] id_ex__imm;
   reg  [31:0] id_ex__pc;

   wire  [3:0] id_ex__alu_op;
   wire  [1:0] id_ex__alu_a_src;
   wire        id_ex__alu_b_src;

   wire  [1:0] id_ex__dmem_width;
   wire        id_ex__dmem_zero_ext;
   wire        id_ex__dmem_read;
   wire        id_ex__dmem_write;

   wire        id_ex__jump_base_src;
   wire  [1:0] id_ex__jump_cond;

   wire        id_ex__rd_wen;
   wire  [1:0] id_ex__rd_src;
   wire  [4:0] id_ex__rd_addr;

   /* ex -> mb */
   wire [31:0] ex_mb__pc;
   wire [31:0] ex_mb__pc_4;
   reg  [31:0] ex_mb__imm;
   wire [31:0] ex_mb__rs1_rdata;
   wire [31:0] ex_mb__rs2_rdata;
   wire [31:0] ex_mb__alu_y;
   wire        ex_mb__alu_zero;
   reg   [1:0] ex_mb__dmem_width;
   reg         ex_mb__dmem_zero_ext;
   reg         ex_mb__dmem_read = 0;
   reg         ex_mb__dmem_write = 0;
   reg         ex_mb__jump_base_src;
   reg   [1:0] ex_mb__jump_cond;

   reg         ex_mb__rd_wen;
   reg   [1:0] ex_mb__rd_src;
   reg   [4:0] ex_mb__rd_addr;

   /* mb -> if */
   wire [31:0] mb_if__jump_target;
   wire        mb_if__jump_taken;

   /* mb -> wb */
   reg   [1:0] mb_wb__rd_src;
   reg  [31:0] mb_wb__alu_y;
   reg  [31:0] mb_wb__pc_4;
   reg         mb_wb__rd_wen = 0;
   reg   [4:0] mb_wb__rd_addr;

   wire  [1:0] mb_wb__dmem_width;
   wire        mb_wb__dmem_zero_ext;
   wire  [1:0] mb_wb__dmem_word_addr;
   wire [31:0] mb_wb__dmem_rdata;

   /* wb -> id */
   wire        wb_id__rd_wen;
   wire  [4:0] wb_id__rd_addr;
   wire [31:0] wb_id__rd_wdata;

   /* fetch */

   fetch cpu_fetch ( .clk(clk)
                   , .data_hazard(data_hazard)
                   , .mb_if__jump_target(mb_if__jump_target)
                   , .mb_if__jump_taken(mb_if__jump_taken)
                   // output
                   , .if_id__pc(if_id__pc)
                   , .if_id__ins(if_id__ins)
                   , .pipe_flush(pipe_flush)
                   );

   /* decode */

   decode cpu_decode ( .clk(clk)
                     , .pipe_flush(pipe_flush)

                     , .if_id__pc(if_id__pc)
                     , .if_id__ins(if_id__ins)

                     , .wb_id__rd_wen(wb_id__rd_wen)
                     , .wb_id__rd_addr(wb_id__rd_addr)
                     , .wb_id__rd_wdata(wb_id__rd_wdata)

                     // output
                     , .id_ex__pc(id_ex__pc)

                     , .id_ex__imm(id_ex__imm)
                     , .id_ex__rs1_rdata(id_ex__rs1_rdata)
                     , .id_ex__rs2_rdata(id_ex__rs2_rdata)
                     , .id_ex__rs1_addr(id_ex__rs1_addr)
                     , .id_ex__rs2_addr(id_ex__rs2_addr)
                     , .id_ex__rd_addr(id_ex__rd_addr)

                     , .id_ex__alu_op(id_ex__alu_op)
                     , .id_ex__alu_a_src(id_ex__alu_a_src)
                     , .id_ex__alu_b_src(id_ex__alu_b_src)

                     , .id_ex__dmem_width(id_ex__dmem_width)
                     , .id_ex__dmem_zero_ext(id_ex__dmem_zero_ext)
                     , .id_ex__dmem_read(id_ex__dmem_read)
                     , .id_ex__dmem_write(id_ex__dmem_write)

                     , .id_ex__jump_base_src(id_ex__jump_base_src)
                     , .id_ex__jump_cond(id_ex__jump_cond)

                     , .id_ex__rd_wen(id_ex__rd_wen)
                     , .id_ex__rd_src(id_ex__rd_src)

                     , .data_hazard(data_hazard)
                     );

   /* execute */

   execute cpu_execute ( .clk(clk)
                       , .pipe_flush(pipe_flush)

                       , .id_ex__rs1_rdata(id_ex__rs1_rdata)
                       , .id_ex__rs2_rdata(id_ex__rs2_rdata)
                       , .id_ex__imm(id_ex__imm)
                       , .id_ex__pc(id_ex__pc)
                       , .id_ex__alu_a_src(id_ex__alu_a_src)
                       , .id_ex__alu_b_src(id_ex__alu_b_src)
                       , .id_ex__alu_op(id_ex__alu_op)
                       // forwarding_unit
                       , .id_ex__rs1_addr(id_ex__rs1_addr)
                       , .id_ex__rs2_addr(id_ex__rs2_addr)
                       , .ex_mb__rd_addr(ex_mb__rd_addr)
                       , .mb_wb__rd_addr(mb_wb__rd_addr)
                       , .ex_mb__rd_wen(ex_mb__rd_wen)
                       , .mb_wb__rd_wen(mb_wb__rd_wen)
                       , .wb_id__rd_wdata(wb_id__rd_wdata)
                       // output
                       , .ex_mb__alu_y(ex_mb__alu_y)
                       , .ex_mb__alu_zero(ex_mb__alu_zero)
                       , .ex_mb__pc(ex_mb__pc)
                       , .ex_mb__pc_4(ex_mb__pc_4)
                       // forwarding unit output
                       , .ex_mb__rs1_rdata(ex_mb__rs1_rdata)
                       , .ex_mb__rs2_rdata(ex_mb__rs2_rdata)
                       );

   // if/ex -> ex/mb passthrough
   always @(posedge clk) begin
      ex_mb__imm <= id_ex__imm;

      ex_mb__dmem_width <= id_ex__dmem_width;
      ex_mb__dmem_zero_ext <= id_ex__dmem_zero_ext;
      ex_mb__dmem_read <= pipe_flush ? 1'b0 : id_ex__dmem_read;
      ex_mb__dmem_write <= pipe_flush ? 1'b0 : id_ex__dmem_write;

      ex_mb__jump_base_src <= id_ex__jump_base_src;
      ex_mb__jump_cond <= pipe_flush ? `COND_NEVER : id_ex__jump_cond;

      ex_mb__rd_src <= id_ex__rd_src;
      ex_mb__rd_wen <= pipe_flush ? 1'b0 : id_ex__rd_wen;
      ex_mb__rd_addr <= id_ex__rd_addr;
   end

   /* mb/wb */

   mem_branch cpu_mem_branch ( .clk(clk)
                             , .ex_mb__pc(ex_mb__pc)
                             , .ex_mb__imm(ex_mb__imm)
                             , .ex_mb__rs1_rdata(ex_mb__rs1_rdata)
                             , .ex_mb__rs2_rdata(ex_mb__rs2_rdata)
                             , .ex_mb__alu_y(ex_mb__alu_y)
                             , .ex_mb__alu_zero(ex_mb__alu_zero)
                             , .ex_mb__dmem_width(ex_mb__dmem_width)
                             , .ex_mb__dmem_zero_ext(ex_mb__dmem_zero_ext)
                             , .ex_mb__dmem_read(ex_mb__dmem_read)
                             , .ex_mb__dmem_write(ex_mb__dmem_write)
                             , .ex_mb__jump_base_src(ex_mb__jump_base_src)
                             , .ex_mb__jump_cond(ex_mb__jump_cond)
                             // output
                             , .mb_if__jump_target(mb_if__jump_target)
                             , .mb_if__jump_taken(mb_if__jump_taken)

                             , .mb_wb__dmem_width(mb_wb__dmem_width)
                             , .mb_wb__dmem_zero_ext(mb_wb__dmem_zero_ext)
                             , .mb_wb__dmem_word_addr(mb_wb__dmem_word_addr)
                             , .mb_wb__dmem_rdata(mb_wb__dmem_rdata)
                             );

   reg [31:0] mb_wb__pc; // debug-only
   // ex/mb -> mb/wb passthrough
   always @(posedge clk) begin
      mb_wb__rd_src <= ex_mb__rd_src;
      mb_wb__alu_y <= ex_mb__alu_y;
      mb_wb__pc <= pipe_flush ? 32'hffffffff : ex_mb__pc; // debug-only
      mb_wb__pc_4 <= ex_mb__pc_4;
      mb_wb__rd_wen <= pipe_flush ? 1'b0 : ex_mb__rd_wen;
      mb_wb__rd_addr <= ex_mb__rd_addr;
   end

   /* writeback */

   // no clock ; no pipe_flush
   writeback cpu_writeback ( .rd_src(mb_wb__rd_src)
                           , .alu_y(mb_wb__alu_y)
                           , .pc_4(mb_wb__pc_4)

                           , .dmem_width(mb_wb__dmem_width)
                           , .dmem_zero_ext(mb_wb__dmem_zero_ext)
                           , .dmem_word_addr(mb_wb__dmem_word_addr)
                           , .dmem_rdata(mb_wb__dmem_rdata)
                           // output
                           , .rd_wdata(wb_id__rd_wdata)
                           );
   assign wb_id__rd_wen = mb_wb__rd_wen;
   assign wb_id__rd_addr = mb_wb__rd_addr;

   /* debug */
   `ifdef VERILATOR
   initial begin
      if ($test$plusargs("trace") != 0) begin
         $dumpfile("logs/vlt_dump.vcd");
         $dumpvars();
      end
   end

   reg mb_target__mb_pc = 0;
   reg [31:0] last_mb_wb__pc;
   always @(posedge clk) begin
      mb_target__mb_pc <= mb_if__jump_target == ex_mb__pc && mb_if__jump_taken;
      last_mb_wb__pc <= ex_mb__pc;
      if (mb_target__mb_pc && last_mb_wb__pc == mb_wb__pc)
        $finish;
   end
   `endif
endmodule
