module imem
  (
   input             clk,
   input             write_en,
   input             read_en,
   input [7:0]       addr,
   input [31:0]      wdata,
   output reg [31:0] rdata
   );

   reg [31:0] mem [0:255];

   always @(posedge clk) begin
      if (write_en) begin
         mem[addr] <= wdata;
      end

      if (read_en) begin
         rdata <= mem[addr];
      end
   end
endmodule
