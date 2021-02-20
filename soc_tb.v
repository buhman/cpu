module soc_tb;

   reg clk = 0;
   always #2 clk = !clk;

   wire   spi_sck;
   wire   pc_cs;
   wire   pc_mosi;
   soc s (.clk(clk),
          .spi_sck(spi_sck),
          .pc_cs(pc_cs),
          .pc_mosi(pc_mosi)
          );

   initial begin
   end

endmodule
