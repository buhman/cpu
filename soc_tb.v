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


   wire [31:0] a = 1836311903;
   wire [31:0] b = 2971215073;
   initial begin
      /*#1 $display("%h", a + b);
       #1 $finish;*/
      #9000 $finish;
   end

endmodule
