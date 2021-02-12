`include "include.v"

module imem
  (
   input             clk,
   input [7:0]       addr,
   output reg [31:0] data
   );

   reg [31:0] mem [0:255];

   initial begin
      $readmemh(`IMEM_INIT_PATH, mem, 0, `IMEM_INIT_LEN);
   end

   always @(posedge clk) begin
      data <= mem[addr];
   end
endmodule
