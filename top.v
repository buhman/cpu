module top
( input hwclk
, output [31:0] ins
);
   cpu top_cpu ( .clk(hwclk)
               , .ins(ins)
               );
endmodule
