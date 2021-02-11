module test_imem
  (
   input             clk,
   input [7:0]       addr,
   output reg [31:0] data
   );

   reg [31:0] mem [0:255];

   initial begin
      //$readmemh("branch_test.hex", mem, 0, 10);
      $readmemh("branch_test_fib.hex", mem, 0, 6);
   end

   always @(posedge clk) begin
      data <= mem[addr];
   end
endmodule

module cpu_branch_tb;

   reg clk = 0;
   always #2 clk = !clk;

   wire [31:0] imem_addr;
   wire [31:0] imem_data;

   test_imem im (.clk(clk),
                 .addr(imem_addr[9:2]),
                 .data(imem_data)
                 );

   cpu c (.clk(clk),
          .imem_addr(imem_addr),
          .imem_data(imem_data)
          );

   initial begin
      #600 $finish;
   end

   //initial
   //  $monitor("%t %d %h %h", $time, clk, imem_addr, imem_data);

endmodule
