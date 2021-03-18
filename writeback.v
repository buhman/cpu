`include "writeback.vh"

(* nolatches *)
module writeback
( input       [1:0] rd_src
, input      [31:0] alu_y
, input      [31:0] pc_4

, input       [1:0] dmem_width
, input             dmem_zero_ext
, input       [1:0] dmem_word_addr
, input      [31:0] dmem_rdata
// output
, output reg [31:0] rd_wdata
);
   wire [31:0] dmem_rdata_decode;

   dmem_decode wb_dmem_decode ( .width(dmem_width)
                              , .zero_ext(dmem_zero_ext)
                              , .addr(dmem_word_addr)
                              , .rdata(dmem_rdata)
                              , .decode(dmem_rdata_decode)
                              );

   (* always_comb *)
   always @*
     case (rd_src)
       `RD_SRC_ALU_Y      : rd_wdata = alu_y;
       `RD_SRC_DMEM_RDATA : rd_wdata = dmem_rdata_decode;
       `RD_SRC_PC_4       : rd_wdata = pc_4;
       default            : rd_wdata = 32'hffffffff;
     endcase

endmodule
