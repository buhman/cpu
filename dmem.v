`include "state.vh"

module dmem
( input             clk
, input             read
, input      [3:0]  writeb
, input      [10:0] addr
, input      [31:0] wdata
, output reg [31:0] rdata
);
   reg [31:0] mem [0:2047];

   initial
      $readmemh(`DMEM_INIT_PATH, mem);

   always @(posedge clk) begin
      if (writeb[0]) mem[addr][7:0] <= wdata[7:0];
      if (writeb[1]) mem[addr][15:8] <= wdata[15:8];
      if (writeb[2]) mem[addr][23:16] <= wdata[23:16];
      if (writeb[3]) mem[addr][31:24] <= wdata[31:24];

      if (writeb != 0)
        $display("%t dmem_write addr:%h wdata:%h %b", $time, addr, wdata, writeb);

      if (read) begin
         $display("%t dmem_read addr:%h rdata:%h %b", $time, addr, mem[addr], read);
         rdata <= mem[addr];
      end
   end
endmodule
