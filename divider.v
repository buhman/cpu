module divider
  #(parameter P = 1,
    parameter N = 16
    )
   (input clk_in,
    output reg clk_out = 0
    );

   reg [N-1:0] counter = 0;

   always @ (posedge clk_in) begin
      counter <= counter + 1;
      if (counter == P) begin
         clk_out <= ~clk_out;
         counter <= 0;
      end
   end
endmodule
