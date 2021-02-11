module imem
  (
   input             clk,
   input [7:0]       addr,
   output reg [31:0] data
   );

   reg [31:0] mem [0:255];

   initial begin
      $readmemh("branch_test_fib.hex", mem, 0, 7);
   end

   always @(posedge clk) begin
      data <= mem[addr];
   end
endmodule
