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
   output probeF,

   input spi0_sck,
   input spi0_cs,
   input spi0_mosi,
   output spi0_miso,

   output ftdi_tx,
   );

   // cpu

   soc s (.clk(hwclk),
          // spi
          .spi0_sck(spi0_sck),
          .spi0_cs(spi0_cs),
          .spi0_mosi(spi0_mosi),
          .spi0_miso(spi0_miso),
          // uart
          .uart0_tx(ftdi_tx)
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

   assign probeC = spi0_sck;
   assign probeD = spi0_cs;
   assign probeE = spi0_mosi;
   assign probeF = spi0_miso;
endmodule
