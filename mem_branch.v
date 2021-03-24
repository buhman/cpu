`include "dmem_encdec.vh"
`include "control.vh"

module mem_branch
( input         clk
, input         pipe_flush

, input         external_int

, input         ex_mb__ins_illegal
, input         ex_mb__ecall
, input         ex_mb__ebreak

, input         ex_mb__trap_return
, input  [31:0] ex_mb__mtvec_rdata
, input  [31:0] ex_mb__mepc_rdata

, input  [31:0] ex_mb__pc
, input  [31:0] ex_mb__imm
, input  [31:0] ex_mb__rs1_rdata
, input  [31:0] ex_mb__rs2_rdata
, input  [31:0] ex_mb__alu_y

, input   [1:0] ex_mb__dmem_width
, input         ex_mb__dmem_zero_ext
, input         ex_mb__dmem_read
, input         ex_mb__dmem_write

, input         ex_mb__jump_base_src
, input   [1:0] ex_mb__jump_cond

// output
, output     [31:0] mb_if__jump_target
, output            mb_if__branch_taken

, output     [31:0] mb_ex__trap_pc
, output            mb_if__trap_taken
, output      [4:0] mb_ex__trap_src
, output     [31:0] mb_ex__dmem_addr

, output reg  [1:0] mb_wb__dmem_width
, output reg        mb_wb__dmem_zero_ext
, output reg  [1:0] mb_wb__dmem_word_addr
, output     [31:0] mb_wb__dmem_rdata
);
   // input wires

   wire        dmem_write = !pipe_flush && ex_mb__dmem_write;
   wire [31:0] dmem_wdata = ex_mb__rs2_rdata;
   wire [31:0] dmem_addr = ex_mb__alu_y;
   wire  [1:0] dmem_word_addr = dmem_addr[1:0];
   assign mb_ex__dmem_addr = dmem_addr;

   // output wires

   wire misalign = (ex_mb__dmem_width == `ENCDEC_HALF && dmem_word_addr == 2'b11)
                || (ex_mb__dmem_width == `ENCDEC_WORD && dmem_word_addr != 2'b00);
   wire load_misalign = misalign && ex_mb__dmem_read;
   wire store_misalign = misalign && ex_mb__dmem_write;

   wire  [3:0] dmem_writeb;
   wire [31:0] dmem_wdata__encode;

   assign mb_ex__trap_pc = ex_mb__pc;

   dmem_encode mb_dmem_encode ( .width(ex_mb__dmem_width)
                              , .addr(dmem_word_addr)
                              , .write(dmem_write)
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

   /* FIXME : maybe this should come from csr_reg instead */
   reg         last_external_int = 0;
   wire        clear_int = last_external_int && !pipe_flush;
   wire        set_int = !last_external_int && external_int;
   always @(posedge clk) begin
      if (clear_int) last_external_int <= 0;
      if (set_int) last_external_int <= 1;
   end

   jump mb_jump ( .pipe_flush(pipe_flush)

                , .pc(ex_mb__pc)
                , .imm(ex_mb__imm)
                , .rs1_rdata(ex_mb__rs1_rdata)
                , .alu_y_lsb(ex_mb__alu_y[0])
                , .base_src(ex_mb__jump_base_src)
                , .cond(ex_mb__jump_cond)

                // trap control
                , .external_int(last_external_int)

                , .ins_illegal(ex_mb__ins_illegal)
                , .ecall(ex_mb__ecall)
                , .ebreak(ex_mb__ebreak)
                , .store_misalign(store_misalign)
                , .load_misalign(load_misalign)

                , .trap_return(ex_mb__trap_return)
                , .mtvec_rdata(ex_mb__mtvec_rdata)
                , .mepc_rdata(ex_mb__mepc_rdata)

                // outputs
                , .jump_target(mb_if__jump_target)
                , .branch_taken(mb_if__branch_taken)
                , .trap_taken(mb_if__trap_taken)
                , .trap_src(mb_ex__trap_src)
                );

   always @(posedge clk) begin
      mb_wb__dmem_width <= ex_mb__dmem_width;
      mb_wb__dmem_zero_ext <= ex_mb__dmem_zero_ext;
      mb_wb__dmem_word_addr <= dmem_word_addr;
   end
endmodule
