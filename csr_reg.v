`include "control.vh"

(* nolatches *)
module csr_reg
( input             clk
, input      [11:0] addr
, input       [1:0] op
, input      [31:0] wdata
// trap state
, input      [31:0] pc
, input             trap
, input       [4:0] trap_src
// output
, output reg [31:0] rdata
, output     [31:0] mtvec_rdata
);
   `include "csr_reg.vh"

   reg [31:0] regs [0:15];
   reg  [3:0] csr;

   initial
     regs[0] = 32'h00000000;

   assign mtvec_rdata = 32'h00000000;

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

   wire [31:0] cause_decode = {trap_src[4], {27{1'b0}}, trap_src[3:0]};

   genvar     i;
   generate
      for (i = 0; i < 32; i = i + 1) begin
         always @(posedge clk) begin
            if (!trap && csr != 0)
              case (op)
                `CSR_NOP   : ;
                `CSR_WRITE : regs[csr][i] <= wdata[i];
                `CSR_SET   : if (wdata[i]) regs[csr][i] <= 1'b1;
                `CSR_CLEAR : if (wdata[i]) regs[csr][i] <= 1'b0;
              endcase
         end
      end
   endgenerate

   always @(posedge clk) begin
      if (trap)
        regs[mepc] <= pc;

      rdata <= regs[csr];
   end

endmodule
