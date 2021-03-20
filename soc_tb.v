module soc_tb;

   reg clk = 0;
   always #1 clk = !clk;

   soc s (.clk(clk)
          );

   initial begin
   end

endmodule
