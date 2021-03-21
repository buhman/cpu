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
, input      [31:0] dmem_addr
, input             pipe_flush
// counters
, input             instret
// output
, output reg [31:0] rdata
, output reg [31:0] mtvec_rdata
, output reg [31:0] mepc_rdata
);
   `include "csr_reg.vh"

   reg [31:0] regs [0:`CSR_LAST];
   reg  [2:0] csr;

   initial begin
      regs[0]        = 32'h00000000;
      regs[mtvec]    = 32'h00000000;
      `ifdef ENABLE_COUNTERS
      regs[mcycle]   = 32'h00000000;
      regs[minstret] = 32'h00000000;
      `endif
   end

   (* always_comb *)
   always @*
     case (addr)
       mepc_addr     : csr = mepc;
       mtvec_addr    : csr = mtvec;

       mcause_addr   : csr = mcause;
       mtval_addr    : csr = mtval;
       `ifdef ENABLE_COUNTERS
       mcycle_addr   : csr = mcycle;
       minstret_addr : csr = minstret;
       `endif
       default       : csr = 0;
     endcase

   genvar     i;
   generate
      for (i = 0; i < 32; i = i + 1) begin
         always @(posedge clk) begin
            if (!trap_write && csr != 0)
              case (op)
                `CSR_NOP   : ;
                `CSR_WRITE : regs[csr][i] <= wdata[i];
                `CSR_SET   : if (wdata[i]) regs[csr][i] <= 1'b1;
                `CSR_CLEAR : if (wdata[i]) regs[csr][i] <= 1'b0;
              endcase
         end
      end
   endgenerate

   reg  [4:0] last_trap_src;
   reg [31:0] last_dmem_addr;

   wire [31:0] cause_decode = {last_trap_src[4], {27{1'b0}}, last_trap_src[3:0]};
   reg   [1:0] trap_state = 0;
   wire        trap_flush = trap && !pipe_flush;
   wire        trap_write = trap_flush || (trap_state != 0);

   (* always_ff *)
   always @(posedge clk) begin
      if (trap_write)
        case (trap_state)
          2'd0: begin
             regs[mepc] <= pc;
             last_trap_src <= trap_src;
             last_dmem_addr <= dmem_addr;
             trap_state <= 1;
          end
          2'd1: begin
             regs[mcause] <= cause_decode;
             trap_state <= 2;
          end
          2'd2: begin
             regs[mtval] <= last_dmem_addr;
             trap_state <= 0;
          end
          default: ;
        endcase

      mepc_rdata <= regs[mepc];
      mtvec_rdata <= regs[mtvec];

      rdata <= regs[csr];
   end


   /* performance counters */

   // ice40: 216 LC
   `ifdef ENABLE_COUNTERS

   (* always_ff *)
   always @(posedge clk) begin
      if (instret)
        regs[minstret] <= regs[minstret] + 1;

      regs[mcycle] <= regs[mcycle] + 1;
   end
   `endif

endmodule
