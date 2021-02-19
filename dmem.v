`include "include.v"

module dmem
  (
   input             clk,
   input [3:0]       writeb,
   input             read,
   input [7:0]       addr,
   input [31:0]      wdata,
   output reg [31:0] rdata
   );

   reg [31:0] mem [0:255];

`ifdef DMEM_INIT_PATH
   initial
      $readmemh(`DMEM_INIT_PATH, mem, 0, `DMEM_INIT_LEN);
`endif

   always @(posedge clk) begin
      if (writeb[0]) mem[addr][7:0] <= wdata[7:0];
      if (writeb[1]) mem[addr][15:8] <= wdata[15:8];
      if (writeb[2]) mem[addr][23:16] <= wdata[23:16];
      if (writeb[3]) mem[addr][31:24] <= wdata[31:24];

      if (writeb[0])
        $display("%t dmem_write addr:%h rdata:%h %d %d", $time, addr, mem[addr], read, writeb[0]);

      if (read) begin
         $display("%t dmem_read addr:%h rdata:%h %d %d", $time, addr, mem[addr], read, writeb[0]);
         rdata <= mem[addr];
      end
   end
endmodule
