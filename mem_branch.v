`include "dmem_encdec.vh"
`include "control.vh"

module mem_branch
( input         clk
, input         pipe_flush

, input         ex_mb__ins_misalign
, input         ex_mb__ins_illegal
, input         ex_mb__ecall
, input         ex_mb__ebreak

, input  [31:0] ex_mb__pc
, input  [31:0] ex_mb__imm
, input  [31:0] ex_mb__rs1_rdata
, input  [31:0] ex_mb__rs2_rdata
, input  [31:0] ex_mb__alu_y
, input         ex_mb__alu_zero

, input   [1:0] ex_mb__dmem_width
, input         ex_mb__dmem_zero_ext
, input         ex_mb__dmem_read
, input         ex_mb__dmem_write

, input         ex_mb__jump_base_src
, input   [1:0] ex_mb__jump_cond

, input  [11:0] ex_mb__csr_addr
, input   [1:0] ex_mb__csr_op
, input         ex_mb__csr_src
// output
, output     [31:0] mb_if__jump_target
, output            mb_if__branch_taken
, output            mb_if__trap_taken

, output reg  [1:0] mb_wb__dmem_width
, output reg        mb_wb__dmem_zero_ext
, output reg  [1:0] mb_wb__dmem_word_addr
, output     [31:0] mb_wb__dmem_rdata

, output     [31:0] mb_wb__csr_rdata
);
   // input wires

   wire [31:0] dmem_wdata = ex_mb__rs2_rdata;
   wire [31:0] dmem_addr = ex_mb__alu_y;
   wire  [1:0] dmem_word_addr = dmem_addr[1:0];

   // output wires

   wire misalign = (ex_mb__dmem_width == `ENCDEC_HALF && dmem_word_addr == 2'b11)
                  || (ex_mb__dmem_width == `ENCDEC_WORD && dmem_word_addr != 2'b00);
   wire load_misalign = misalign && ex_mb__dmem_read;
   wire store_misalign = misalign && ex_mb__dmem_write;

   wire  [3:0] dmem_writeb;
   wire [31:0] dmem_wdata__encode;

   dmem_encode mb_dmem_encode ( .width(ex_mb__dmem_width)
                              , .addr(dmem_word_addr)
                              , .write(ex_mb__dmem_write)
                              , .wdata(dmem_wdata)
                                // output
                              , .writeb(dmem_writeb)
                              , .encode(dmem_wdata__encode)
                              );

   dmem mb_dmem ( .clk(clk)
                , .read(ex_mb__dmem_read)
                , .writeb(dmem_writeb)
                , .addr(dmem_addr[12:2])
                , .wdata(dmem_wdata__encode)
                // output
                , .rdata(mb_wb__dmem_rdata)
                );

   wire [31:0] csr_wdata = (ex_mb__csr_src == `CSR_SRC_RS1) ? ex_mb__rs1_rdata :
                           ex_mb__imm;

   wire  [4:0] trap_src;
   wire [31:0] mtvec_rdata;

   csr_reg mb_csr_reg ( .clk(clk)
                      , .addr(ex_mb__csr_addr)
                      , .op(ex_mb__csr_op)
                      , .wdata(csr_wdata)
                      // trap state
                      , .pc(ex_mb__pc)
                      , .trap(mb_if__trap_taken)
                      , .trap_src(trap_src)
                      // output
                      , .rdata(mb_wb__csr_rdata)
                      , .mtvec_rdata(mtvec_rdata)
                      );

   jump mb_jump ( .pipe_flush(pipe_flush)

                , .pc(ex_mb__pc)
                , .imm(ex_mb__imm)
                , .rs1_rdata(ex_mb__rs1_rdata)
                , .alu_zero(ex_mb__alu_zero)
                , .base_src(ex_mb__jump_base_src)
                , .cond(ex_mb__jump_cond)
                // trap control
                , .ins_illegal(ex_mb__ins_illegal)
                , .ins_misalign(ex_mb__ins_misalign)
                , .ecall(ex_mb__ecall)
                , .ebreak(ex_mb__ebreak)
                , .store_misalign(store_misalign)
                , .load_misalign(load_misalign)

                , .mtvec_rdata(mtvec_rdata)
                // outputs
                , .jump_target(mb_if__jump_target)
                , .branch_taken(mb_if__branch_taken)
                , .trap_taken(mb_if__trap_taken)
                , .trap_src(trap_src)
                );

   always @(posedge clk) begin
      mb_wb__dmem_width <= ex_mb__dmem_width;
      mb_wb__dmem_zero_ext <= ex_mb__dmem_zero_ext;
      mb_wb__dmem_word_addr <= dmem_word_addr;
   end
endmodule
