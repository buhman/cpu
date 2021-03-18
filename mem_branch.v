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
, output [31:0] mb_if__jump_target
, output        mb_if__jump_taken
, output [31:0] mb_wb__dmem_rdata
);
   wire [31:0] dmem_rdata__decode;
   wire [31:0] dmem_wdata__encode;

   wire [31:0] dmem_rdata;
   wire [31:0] dmem_wdata;

   wire [3:0]  dmem_writeb;
   wire        dmem_unaligned;

   wire [31:0] dmem_addr;

   wire        unaligned;

   assign dmem_wdata = ex_mb__rs2_rdata;
   assign dmem_addr = ex_mb__alu_y;
   assign mb_wb__dmem_rdata = dmem_rdata__decode;

   assign unaligned = (ex_mb__dmem_read || ex_mb__dmem_write) && dmem_unaligned;

   dmem mem_branch_dmem ( .clk(clk)
                        , .read(ex_mb__dmem_read)
                        , .writeb(dmem_writeb)
                        , .addr(dmem_addr[12:2])
                        , .wdata(dmem_wdata__encode)
                        // output
                        , .rdata(dmem_rdata)
                        );

   word_encdec mem_branch_word_encdec (
                     .width(ex_mb__dmem_width)
                   , .zero_ext(ex_mb__dmem_zero_ext)
                   , .addr(dmem_addr[1:0])
                   , .rdata(dmem_rdata)
                   , .wdata(dmem_wdata)
                   , .write(ex_mb__dmem_write)
                   // outputs
                   , .decode(dmem_rdata__decode)
                   , .encode(dmem_wdata__encode)
                   , .unaligned(dmem_unaligned)
                   , .writeb(dmem_writeb)
                   );

   jump mem_branch_jump ( .pc(ex_mb__pc)
                        , .imm(ex_mb__imm)
                        , .rs1_rdata(ex_mb__rs1_rdata)
                        , .alu_zero(ex_mb__alu_zero)
                        , .base_src(ex_mb__jump_base_src)
                        , .cond(ex_mb__jump_cond)
                        // outputs
                        , .target(mb_if__jump_target)
                        , .taken(mb_if__jump_taken)
                        );
endmodule
