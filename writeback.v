`include "writeback.vh"

(* nolatches *)
module writeback
( input       [1:0] rd_src
, input      [31:0] dmem_rdata
, input      [31:0] alu_y
, input      [31:0] pc_4
, output reg [31:0] rd_wdata
);

   (* always_comb *)
   always @*
     case (rd_src)
       `RD_SRC_ALU_Y      : rd_wdata = alu_y;
       `RD_SRC_DMEM_RDATA : rd_wdata = dmem_rdata;
       `RD_SRC_PC_4       : rd_wdata = pc_4;
       default            : rd_wdata = 32'hffffffff;
     endcase

endmodule
