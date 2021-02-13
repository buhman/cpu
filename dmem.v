module dmem
  (
   input         clk,
   input         write,
   input         read,
   input [7:0]   addr,
   input [31:0]  wdata,
   output reg [31:0] rdata
   );

   reg [31:0] mem [0:255];

   always @(posedge clk) begin
      if (write) begin
         $display("%t WRITE addr:%h wdata:%h", $time, addr, wdata);
         mem[addr] <= wdata;
      end

      if (read) begin
         rdata <= mem[addr];
      end
   end
endmodule
