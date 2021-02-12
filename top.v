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

   parameter period_1 = 10000;
   reg [31:0] cntr_1 = 32'b0;
   reg        clk_1 = 0;

   always @(posedge hwclk) begin
      cntr_1 <= cntr_1 + 1;
      if (cntr_1 == period_1) begin
         clk_1 <= ~clk_1;
         cntr_1 <= 32'b0;
      end
   end

   parameter period_2 = 3;
   reg [1:0] cntr_2 = 0;
   reg       clk_2 = 0;

   always @(posedge clk_1) begin
      cntr_2 <= cntr_2 + 1;
      if (cntr_2 == period_2) begin
         clk_2 <= ~clk_2;
         cntr_2 <= 2'b0;
      end
   end

   // cpu

   wire [31:0] imem_data;
   wire [31:0] imem_addr;
   wire        dmem_write;
   wire        dmem_read;
   wire [31:0] dmem_addr;
   wire [31:0] dmem_wdata;
   wire [31:0] dmem_rdata;
   wire [31:0] alu_out;

   cpu c (.clk(clk_2),
          .imem_addr(imem_addr),
          .imem_data(imem_data),
          .dmem_write(dmem_write),
          .dmem_read(dmem_read),
          .dmem_addr(dmem_addr),
          .dmem_wdata(dmem_wdata),
          .dmem_rdata(dmem_rdata)
          );

   // imem

   imem im (.clk(clk_2),
            .addr(imem_addr[9:2]),
            .data(imem_data)
            );

   // dmem

   dmem dm (.clk(clk_2),
            .write(dmem_write),
            .read(dmem_read),
            .addr(dmem_addr[9:2]),
            .wdata(dmem_wdata),
            .rdata(dmem_rdata)
            );

   // io

   wire [6:0]  leds_out;

   assign {led2, led3, led4, led5, led6, led7, led8} = leds_out;

   assign leds_out[6:0] = imem_addr[8:2];
   assign led1 = clk_2;

   wire [8:0]   memL;

   assign {mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7} = memL;

   /*
   always @(posedge clk_1) begin
      if (data_out) begin
         case (cntr_2)
           0: memL <= dmem_wdata[7:0];
           1: memL <= dmem_wdata[15:8];
           2: memL <= dmem_wdata[23:16];
           3: begin
              memL <= dmem_wdata[31:24];
              data_out <= 0;
           end
           default: memL <= 0;
         endcase
      end
      else begin
         memL <= 0;
         if (dmem_write)
           data_out <= 1;
      end
   end
    */
   assign {mem8, mem9, memA, memB, memC, memD} = imem_addr[7:2];
   assign memL = imem_data[7:0];

   reg data_out = 0;

   assign memF = data_out ? clk_1 : 0;
   assign memE = clk_2;


endmodule
