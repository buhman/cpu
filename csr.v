module csr_regs (
                 input             clk,
                 input [11:0]      addr,
                 input             stage0,
                 output reg [31:0] rdata
                 );
   reg [31:0] rdcycle = 0;
   //reg [31:0] rdtime = 0;
   reg [31:0] rdinstret = 0;

   localparam c_cycle = 12'hc00;
   localparam c_time = 12'hc01;
   localparam c_instret = 12'hc02;
   localparam c_cycleh = 12'hc80;
   localparam c_timeh = 12'hc81;
   localparam c_instreth = 12'hc82;

   always @* begin
      case (addr)
        c_cycle: rdata = rdcycle[31:0];
        //c_time: rdata = rdtime[31:0];
        c_time: rdata = rdcycle[31:0];
        c_instret: rdata = rdinstret[31:0];
        /*
        c_cycleh: rdata = rdcycle[63:32];
        //c_timeh: rdata = rdtime[63:32];
        c_timeh: rdata = rdcycle[63:32];
        c_instreth: rdata = rdinstret[63:32];
         */
        default: rdata = 32'hffffffff;
      endcase
   end

   always @(posedge clk) begin
      rdcycle <= rdcycle + 1;
      if (stage0)
        rdinstret <= rdinstret + 1;
   end
endmodule
