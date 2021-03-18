`include "dmem_encdec.vh"

module mem_branch
( input         clk
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
, input   	ex_mb__jump_base_src
, input   [1:0] ex_mb__jump_cond
// output
, output     [31:0] mb_if__jump_target
, output            mb_if__jump_taken

, output reg  [1:0] mb_wb__dmem_width
, output reg        mb_wb__dmem_zero_ext
, output reg  [1:0] mb_wb__dmem_word_addr
, output     [31:0] mb_wb__dmem_rdata
);
   // input wires

   wire [31:0] dmem_wdata = ex_mb__rs2_rdata;
   wire [31:0] dmem_addr = ex_mb__alu_y;
   wire  [1:0] dmem_word_addr = dmem_addr[1:0];

   // output wires

   wire dmem_unaligned = (ex_mb__dmem_width == `ENCDEC_HALF && dmem_word_addr == 2'b11)
                      || (ex_mb__dmem_width == `ENCDEC_WORD && dmem_word_addr != 2'b00);
   wire unaligned = dmem_unaligned && (ex_mb__dmem_read || ex_mb__dmem_write);

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

   jump mb_jump ( .pc(ex_mb__pc)
                , .imm(ex_mb__imm)
                , .rs1_rdata(ex_mb__rs1_rdata)
                , .alu_zero(ex_mb__alu_zero)
                , .base_src(ex_mb__jump_base_src)
                , .cond(ex_mb__jump_cond)
                // outputs
                , .target(mb_if__jump_target)
                , .taken(mb_if__jump_taken)
                );

   always @(posedge clk) begin
      mb_wb__dmem_width <= ex_mb__dmem_width;
      mb_wb__dmem_zero_ext <= ex_mb__dmem_zero_ext;
      mb_wb__dmem_word_addr <= dmem_word_addr;
   end
endmodule
