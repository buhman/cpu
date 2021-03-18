`include "state.vh"

module imem
( input             clk
, input       [7:0] addr
, input             read
, output reg [31:0] data
);
   reg [31:0] mem [0:255];

   initial
      $readmemh(`IMEM_INIT_PATH, mem);

   always @(posedge clk) begin
      if (read)
        data <= mem[addr];
   end
endmodule
