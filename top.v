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

   output probe0,
   output probe1,
   output probe2,
   output probe3,
   output probe4,
   output probe5,
   output probe6,
   output probe7,
   output probe8,
   output probe9,
   output probeA,
   output probeB,
   output probeC,
   output probeD,
   output probeE,
   output probeF
   );

   // cpu


   wire   cpu_clk;
   wire   spi_sck;
   wire   pc_mosi;
   wire   pc_cs;
   wire   imem_data_mosi;
   wire   imem_data_cs;
   wire   dmem_wdata_mosi;
   wire   dmem_wdata_cs;
   wire   dmem_rdata_mosi;
   wire   dmem_rdata_cs;

   soc s (.clk(hwclk),
          .cpu_clk(cpu_clk),
          .spi_sck(spi_sck),
          .pc_mosi(pc_mosi),
          .pc_cs(pc_cs),
          .imem_data_mosi(imem_data_mosi),
          .imem_data_cs(imem_data_cs),
          .dmem_wdata_mosi(dmem_wdata_mosi),
          .dmem_wdata_cs(dmem_wdata_cs),
          .dmem_rdata_mosi(dmem_rdata_mosi),
          .dmem_rdata_cs(dmem_rdata_cs)
          );

   // io

   wire [7:0] led;
   assign {led1, led2, led3, led4, led5, led6, led7, led8} = led;
   assign led[0] = cpu_clk;
   assign led[1] = dmem_wdata_cs;
   assign led[2] = dmem_rdata_cs;

   /*
   wire [15:0] probe;
   assign {probeF, probeE, probeD, probeC, probeB, probeA, probe9, probe8,
           probe7, probe6, probe5, probe4, probe3, probe2, probe1, probe0
           } = probe;
    */

   assign probe0 = cpu_clk;
   assign probe1 = spi_sck;
   assign probe2 = pc_cs;
   assign probe3 = pc_mosi;
   assign probe4 = imem_data_cs;
   assign probe5 = imem_data_mosi;
   assign probe6 = dmem_wdata_cs;
   assign probe7 = dmem_wdata_mosi;
   assign probe8 = dmem_rdata_cs;
   assign probe9 = dmem_rdata_mosi;

endmodule
