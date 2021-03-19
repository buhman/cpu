`include "control.vh"

(* nolatches *)
module csr_reg
( input             clk
, input      [11:0] addr
, input       [1:0] op
, input      [31:0] wdata
, output reg [31:0] rdata
);
   `include "csr_reg.vh"

   reg [31:0] regs [0:15];
   reg  [3:0] csr;

   initial
     regs[0] = 32'h00000000;

   (* always_comb *)
   always @*
     case (addr)
       mscratch_addr : csr = mscratch;
       mepc_addr     : csr = mepc;
       mcause_addr   : csr = mcause;
       mtval_addr    : csr = mtval;
       mip_addr      : csr = mip;
       default       : csr = 0;
     endcase

   always @(posedge clk) begin
      case (op)
        `CSR_NOP   : ;
        `CSR_WRITE : regs[csr] <= wdata;
        `CSR_SET   : regs[csr] <= regs[csr] | wdata;
        `CSR_CLEAR : regs[csr] <= regs[csr] & ~wdata;
      endcase

      if (csr != 0)
        rdata <= regs[csr];
   end

endmodule
