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
// counters
, input             pipe_flush
, input             data_hazard
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
   wire        trap_write = trap || (trap_state != 0);

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
   reg [31:0] next_minstret = 32'h00000001;

   reg  [1:0] pipe_flush_ctr = 2'd0;
   wire       pipe_flush_zero = pipe_flush_ctr == 2'd0;

   reg  [1:0] data_hazard_ctr = 2'd0;
   wire       data_hazard_zero = data_hazard_ctr == 2'd0;
   wire       data_hazard_three = data_hazard_ctr == 2'd3;

   wire       instret = !data_hazard_three && !pipe_flush && pipe_flush_zero;

   (* always_ff *)
   always @(posedge clk) begin
      if (pipe_flush) pipe_flush_ctr <= 2'd2;
      if (!pipe_flush_zero) pipe_flush_ctr <= pipe_flush_ctr + 2'd1;

      if (data_hazard) data_hazard_ctr <= 2'd2;
      if (!data_hazard_zero) data_hazard_ctr <= data_hazard_ctr + 2'd1;

      if (instret) begin
         next_minstret <= next_minstret + 1;
         regs[minstret] <= next_minstret;
      end

      regs[mcycle] <= regs[mcycle] + 1;
   end
   `endif

endmodule
