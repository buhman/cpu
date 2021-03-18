module cpu_tb;
   reg clk = 0;

   always #1 clk = !clk;

   cpu tb_cpu(.clk(clk));

   initial
     #20 $finish;

endmodule
