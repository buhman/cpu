module top
  (
   input  hwclk,
   output led1,
   output led2,
   output led3,
   output led4,
   output led5,
   output led6,
   output led7,
   output led8,

   output mem0,
   output mem1,
   output mem2,
   output mem3,
   output mem4,
   output mem5,
   output mem6,
   output mem7,
   output mem8,
   output mem9,
   output memA,
   output memB,
   output memC,
   output memD,
   output memE,
   output memF
   );

   // clk

   parameter period_1 = 1000000;
   reg [31:0] cntr_1 = 32'b0;
   reg        clk_1 = 0;

   always @(posedge hwclk) begin
      cntr_1 <= cntr_1 + 1;
      if (cntr_1 == period_1) begin
         clk_1 <= ~clk_1;
         cntr_1 <= 32'b0;
      end
   end

   // cpu

   wire [31:0] imem_data;
   wire [31:0] imem_addr;
   wire [31:0] alu_out;
   wire [31:0] pc_out;

   cpu c (.clk(clk_1),
          .imem_data(imem_data),
          .imem_addr(imem_addr),
          .alu_out(alu_out),
          .leds_out(leds_out),
          );

   // imem

   imem im (.clk(clk_1),
            .addr(imem_addr[9:2]),
            .data(imem_data)
            );

   // io

   wire [6:0]  leds_out;

   always @(leds_out) begin
      {led2, led3, led4, led5, led6, led7, led8} <= leds_out;
   end

   assign led1 = clk_1;
   assign {mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7} = alu_out[7:0];
   assign {mem8, mem9, memA, memB, memC, memD, memE} = imem_addr[8:2];
   assign memF = clk_1;

endmodule
