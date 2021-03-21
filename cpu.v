`include "jump.vh"
`include "control.vh"

module cpu
( input clk
, input external_int
, output [31:0] pc
);
   assign pc = ex_mb__pc;

   wire pipe_flush;
   wire data_hazard;

   /* if -> id */
   wire        if_id__ins_misalign;

   wire [31:0] if_id__pc;
   wire [31:0] if_id__ins;

   wire        if_id__predict_taken;

   wire        if_id__instret;

   /* id -> ex */
   wire        id_ex__ins_misalign;
   wire        id_ex__ins_illegal;
   wire        id_ex__ecall;
   wire        id_ex__ebreak;

   wire        id_ex__trap_return;

   wire [31:0] id_ex__pc;

   wire        if_id__data_hazard;

   wire [31:0] id_ex__rs1_rdata;
   wire [31:0] id_ex__rs2_rdata;
   wire  [4:0] id_ex__rs1_addr;
   wire  [4:0] id_ex__rs2_addr;
   wire [31:0] id_ex__imm;

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

   wire [11:0] id_ex__csr_addr;
   wire  [1:0] id_ex__csr_op;
   wire        id_ex__csr_src;

   reg         id_ex__predict_taken;

   reg         id_ex__instret; // performance counter

   /* ex -> mb */
   reg         ex_mb__ins_misalign;
   reg         ex_mb__ins_illegal;
   reg         ex_mb__ecall;
   reg         ex_mb__ebreak;

   reg         ex_mb__trap_return;

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

   reg  [11:0] ex_mb__csr_addr;
   reg   [1:0] ex_mb__csr_op;
   reg         ex_mb__csr_src;

   reg         ex_mb__predict_taken;

   wire [31:0] ex_mb__csr_rdata;
   wire [31:0] ex_mb__mtvec_rdata;
   wire [31:0] ex_mb__mepc_rdata;

   reg         ex_mb__instret;

   /* mb -> if */
   wire [31:0] mb_if__jump_target;
   wire        mb_if__branch_taken;
   wire        mb_if__trap_taken;
   wire        mb_if__predict_taken = ex_mb__predict_taken;
   wire [31:0] mb_if__pc_4 = ex_mb__pc_4;

   /* mb -> ex */
   wire  [4:0] mb_ex__trap_src;
   wire [31:0] mb_ex__dmem_addr;

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

   reg  [31:0] mb_wb__csr_rdata;

   reg         mb_ex__instret = 0;

   /* wb -> id */
   wire        wb_id__rd_wen;
   wire [31:0] wb_id__rd_wdata;
   wire  [4:0] wb_id__rd_addr;

   /* fetch */

   fetch cpu_fetch ( .clk(clk)
                   , .data_hazard(data_hazard)
                   , .mb_if__jump_target(mb_if__jump_target)
                   , .mb_if__branch_taken(mb_if__branch_taken)
                   , .mb_if__trap_taken(mb_if__trap_taken)
                   , .mb_if__predict_taken(mb_if__predict_taken)
                   , .mb_if__pc_4(mb_if__pc_4)
                   // output
                   , .pipe_flush(pipe_flush)
                   , .if_id__ins_misalign(if_id__ins_misalign)
                   , .if_id__pc(if_id__pc)
                   , .if_id__ins(if_id__ins)
                   , .if_id__predict_taken(if_id__predict_taken)

                   , .if_id__data_hazard(if_id__data_hazard)
                   , .if_id__instret(if_id__instret)
                   );

   /* decode */

   decode cpu_decode ( .clk(clk)
                     , .pipe_flush(pipe_flush)

                     , .if_id__ins_misalign(if_id__ins_misalign)
                     , .if_id__ins(if_id__ins)

                     , .if_id__pc(if_id__pc)

                     , .if_id__data_hazard(if_id__data_hazard)

                     // falling-edge register writeback input
                     , .wb_id__rd_wen(wb_id__rd_wen)
                     , .wb_id__rd_wdata(wb_id__rd_wdata)
                     , .wb_id__rd_addr(wb_id__rd_addr)

                     // output
                     , .id_ex__ins_misalign(id_ex__ins_misalign)
                     , .id_ex__ins_illegal(id_ex__ins_illegal)
                     , .id_ex__ecall(id_ex__ecall)
                     , .id_ex__ebreak(id_ex__ebreak)

                     , .id_ex__trap_return(id_ex__trap_return)

                     , .id_ex__pc(id_ex__pc)

                     , .id_ex__imm(id_ex__imm)
                     , .id_ex__rs1_rdata(id_ex__rs1_rdata)
                     , .id_ex__rs2_rdata(id_ex__rs2_rdata)
                     , .id_ex__rs1_addr(id_ex__rs1_addr)
                     , .id_ex__rs2_addr(id_ex__rs2_addr)

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
                     , .id_ex__rd_addr(id_ex__rd_addr)

                     , .id_ex__csr_addr(id_ex__csr_addr)
                     , .id_ex__csr_op(id_ex__csr_op)
                     , .id_ex__csr_src(id_ex__csr_src)

                     , .data_hazard(data_hazard)
                     );

   /* if/id -> id/ex pass-through */
   always @(posedge clk) begin
      id_ex__predict_taken <= pipe_flush ? 1'b0 : if_id__predict_taken;
      id_ex__instret <= pipe_flush ? 1'b0 : if_id__instret; // performance counter
   end

   /* execute */

   execute cpu_execute ( .clk(clk)
                       , .pipe_flush(pipe_flush)
                       , .data_hazard(data_hazard)

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
                       // control and status register unit
                       , .id_ex__csr_addr(id_ex__csr_addr)
                       , .id_ex__csr_op(id_ex__csr_op)
                       , .id_ex__csr_src(id_ex__csr_src)

                       , .mb_if__trap_taken(mb_if__trap_taken)
                       , .mb_ex__trap_src(mb_ex__trap_src)
                       , .mb_ex__dmem_addr(mb_ex__dmem_addr)

                       , .mb_ex__instret(mb_ex__instret)
                       // output
                       , .ex_mb__alu_y(ex_mb__alu_y)
                       , .ex_mb__alu_zero(ex_mb__alu_zero)
                       , .ex_mb__pc(ex_mb__pc)
                       , .ex_mb__pc_4(ex_mb__pc_4)
                       // forwarding unit output
                       , .ex_mb__rs1_rdata(ex_mb__rs1_rdata)
                       , .ex_mb__rs2_rdata(ex_mb__rs2_rdata)
                       // control and status register unit output
                       , .ex_mb__csr_rdata(ex_mb__csr_rdata)
                       , .ex_mb__mtvec_rdata(ex_mb__mtvec_rdata)
                       , .ex_mb__mepc_rdata(ex_mb__mepc_rdata)
                       );

   // if/ex -> ex/mb passthrough
   always @(posedge clk) begin
      ex_mb__ins_misalign <= pipe_flush ? 1'b0 : id_ex__ins_misalign;
      ex_mb__ins_illegal  <= pipe_flush ? 1'b0 : id_ex__ins_illegal;
      ex_mb__ecall    <= pipe_flush ? 1'b0 : id_ex__ecall;
      ex_mb__ebreak   <= pipe_flush ? 1'b0 : id_ex__ebreak;

      ex_mb__trap_return <= pipe_flush ? 1'b0 : id_ex__trap_return;

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

      ex_mb__csr_addr <= id_ex__csr_addr;
      ex_mb__csr_op <= pipe_flush ? `CSR_NOP : id_ex__csr_op;
      ex_mb__csr_src <= id_ex__csr_src;

      ex_mb__predict_taken <= pipe_flush ? 1'b0 : id_ex__predict_taken;

      ex_mb__instret <= pipe_flush ? 1'b0 : id_ex__instret;
   end

   /* mb/wb */

   mem_branch cpu_mem_branch ( .clk(clk)
                             , .pipe_flush(pipe_flush)

                             , .external_int(external_int)

                             , .ex_mb__ins_misalign(ex_mb__ins_misalign)
                             , .ex_mb__ins_illegal(ex_mb__ins_illegal)
                             , .ex_mb__ecall(ex_mb__ecall)
                             , .ex_mb__ebreak(ex_mb__ebreak)

                             , .ex_mb__trap_return(ex_mb__trap_return)
                             , .ex_mb__mtvec_rdata(ex_mb__mtvec_rdata)
                             , .ex_mb__mepc_rdata(ex_mb__mepc_rdata)

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
                             , .mb_if__branch_taken(mb_if__branch_taken)
                             , .mb_if__trap_taken(mb_if__trap_taken)
                             , .mb_ex__trap_src(mb_ex__trap_src)
                             , .mb_ex__dmem_addr(mb_ex__dmem_addr)

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
      mb_wb__pc <= (mb_if__trap_taken || pipe_flush) ? 32'hffffffff : ex_mb__pc; // debug-only
      mb_wb__pc_4 <= ex_mb__pc_4;
      mb_wb__rd_wen <= (mb_if__trap_taken || pipe_flush) ? 1'b0 : ex_mb__rd_wen;
      mb_wb__rd_addr <= ex_mb__rd_addr;

      mb_wb__csr_rdata <= ex_mb__csr_rdata;

      mb_ex__instret <= (mb_if__trap_taken || pipe_flush) ? 1'b0 : ex_mb__instret;
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

                           , .csr_rdata(mb_wb__csr_rdata)

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
      mb_target__mb_pc <= mb_if__jump_target == ex_mb__pc && mb_if__branch_taken;
      last_mb_wb__pc <= ex_mb__pc;
      if (mb_target__mb_pc && last_mb_wb__pc == mb_wb__pc)
        $finish;
   end
   `endif
endmodule
