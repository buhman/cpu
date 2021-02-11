module test_imem
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

module cpu_branch_tb;

   reg clk = 0;
   always #2 clk = !clk;

   wire [31:0] imem_addr;
   wire [31:0] imem_data;
   wire        dmem_write;
   wire        dmem_read;
   wire [31:0] dmem_addr;
   wire [31:0] dmem_wdata;
   wire [31:0] dmem_rdata;

   test_imem im (.clk(clk),
                 .addr(imem_addr[9:2]),
                 .data(imem_data)
                 );

   dmem dm (.clk(clk),
            .write(dmem_write),
            .read(dmem_read),
            .addr(dmem_addr[9:2]),
            .wdata(dmem_wdata),
            .rdata(dmem_rdata)
            );

   cpu c (.clk(clk),
          .imem_addr(imem_addr),
          .imem_data(imem_data),
          .dmem_write(dmem_write),
          .dmem_read(dmem_read),
          .dmem_addr(dmem_addr),
          .dmem_wdata(dmem_wdata),
          .dmem_rdata(dmem_rdata)
          );

   initial begin
      #600 $finish;
   end

   //initial
   //  $monitor("%t %d %h %h", $time, clk, imem_addr, imem_data);

endmodule
