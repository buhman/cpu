module top
( input hwclk
, output [31:0] pc
);
   cpu top_cpu ( .clk(hwclk)
               , .pc(pc)
               );
endmodule
