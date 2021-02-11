module imem
  (
   input             clk,
   input [7:0]       addr,
   output reg [31:0] data
   );

   reg [31:0] mem [0:255];

   initial begin
      $readmemh("load_store_test_fib.hex", mem, 0, 9);
   end

   always @(posedge clk) begin
      data <= mem[addr];
   end
endmodule
