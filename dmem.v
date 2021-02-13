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
         $display("%t dmem_write addr:%h wdata:%h %d %d", $time, addr, wdata, read, write);
         mem[addr] <= wdata;
      end

      if (read) begin
         $display("%t dmem_read addr:%h rdata:%h %d %d", $time, addr, mem[addr], read, write);
         rdata <= mem[addr];
      end
   end
endmodule
