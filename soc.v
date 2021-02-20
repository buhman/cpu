

module soc
   (input  clk,
    // debug
    output cpu_clk,
    output spi_sck,
    output pc_cs,
    output pc_mosi,
    output imem_data_cs,
    output imem_data_mosi,
    output dmem_wdata_cs,
    output dmem_wdata_mosi,
    output dmem_rdata_cs,
    output dmem_rdata_mosi,
    // spi
    input  spi0_sck,
    input  spi0_cs,
    input  spi0_mosi,
    output spi0_miso,
    // uart
    output uart0_tx
    );

   wire [31:0] imem_data;
   wire [31:0] imem_addr;
   wire [3:0]  dmem_writeb;
   wire        dmem_read;
   wire [31:0] dmem_addr;
   wire [31:0] dmem_wdata;
   reg [31:0]  dmem_rdata;
   wire [31:0] pc_out;

   wire        cpu_clk;

   cpu c (.clk(cpu_clk),
          .imem_addr(imem_addr),
          .imem_data(imem_data),
          .dmem_writeb(dmem_writeb),
          .dmem_read(dmem_read),
          .dmem_addr(dmem_addr),
          .dmem_wdata(dmem_wdata),
          .dmem_rdata(dmem_rdata),
          .pc_out(pc_out)
          );

   imem im (.clk(cpu_clk),
            .addr(imem_addr[9:2]),
            .data(imem_data)
            );

   wire        lm_sel = (dmem_addr[31:16] == 16'h0000);
   wire [3:0] lm_writeb = lm_sel ? dmem_writeb : 4'd0;
   wire       lm_read = lm_sel ? dmem_read : 0;
   wire [31:0] lm_rdata;

   dmem lm (.clk(cpu_clk),
            .writeb(lm_writeb),
            .read(lm_read),
            //.addr(dmem_addr[15:2]),
            .addr(dmem_addr[12:2]),
            .wdata(dmem_wdata),
            .rdata(lm_rdata)
            );

   // spi slave peripheral

   /*
   wire       spi0_sel = (dmem_addr[31:10] == 22'd1);
   wire [3:0] spi0_writeb = spi0_sel ? dmem_writeb : 4'd0;
   wire       spi0_read = spi0_sel ? dmem_read : 0;
   wire [31:0] spi0_rdata;

   spi_slave_mem ssm (.sck(spi0_sck),
                      .cs(spi0_cs),
                      .mosi(spi0_mosi),
                      .miso(spi0_miso),
                      .clk(cpu_clk),
                      .writeb(spi0_writeb),
                      .read(spi0_read),
                      .addr(dmem_addr[9:2]),
                      .wdata(dmem_wdata),
                      .rdata(spi0_rdata)
                      );
    */

   // uart peripheral

   wire       uart0_sel = (dmem_addr[31:8] == 24'hffff07);
   wire [3:0] uart0_writeb = uart0_sel ? dmem_writeb : 4'd0;
   wire       uart0_read = uart0_sel ? dmem_read : 0;
   wire [31:0] uart0_rdata;

   wire        uart_clk;
   divider #(.P(625),
             .N(10)) uart_d (.clk_in(clk),
                             .clk_out(uart_clk)
                             );

   uart_mem uart0 (.uart_clk(uart_clk),
                   .tx(uart0_tx),
                   //
                   .cpu_clk(cpu_clk),
                   .writeb(uart0_writeb),
                   .read(uart0_read),
                   .addr(dmem_addr[7:2]),
                   .wdata(dmem_wdata),
                   .rdata(uart0_rdata)
                   );

   // rdata mux

   always @*
     case (dmem_addr[31:16])
       16'h0000: dmem_rdata = lm_rdata;
       16'hffff: begin
          case (dmem_addr[15:8])
             8'h07: dmem_rdata = uart0_rdata;
             default: dmem_rdata = 32'hfdfdfdfd;
          endcase
       end
       default: dmem_rdata = 32'hfefefefe;
     endcase

   // debug interface

   wire        spi_sck;
   reg         cclk = 0;

   divider #(.P(100),
             .N(7)) sc (.clk_in(clk),
                        .clk_out(spi_sck)
                        );

   always @(negedge spi_sck)
     // cclk is roughly 1/33 of spi_sck
     cclk <= (pc_cs && !cclk);
`ifdef IVERILOG
   assign cpu_clk = clk;
`else
   assign cpu_clk = cclk;
`endif

   /// spi

   spi pc_s (.data(pc_out),
             .sck(spi_sck),
             .mosi(pc_mosi),
             .cs(pc_cs)
             );

   spi imd_s (.data(imem_data),
              .sck(spi_sck),
              .mosi(imem_data_mosi),
              .cs(imem_data_cs)
              );

   wire        dmwd_cs;
   spi dmwd_s (.data(dmem_wdata),
               .sck(spi_sck),
               .mosi(dmem_wdata_mosi),
               .cs(dmwd_cs)
               );
   assign dmem_wdata_cs = dmem_writeb[0] ? dmwd_cs : 1;

   /*
   wire        dmrd_cs;
   spi dmrd_s (.data(dmem_rdata),
               .sck(spi_sck),
               .mosi(dmem_rdata_mosi),
               .cs(dmrd_cs)
               );
   assign dmem_rdata_cs = dmem_read ? dmrd_cs : 1;
    */

   wire        dmrd_cs;
   spi dmrd_s (.data(dmem_addr),
               .sck(spi_sck),
               .mosi(dmem_rdata_mosi),
               .cs(dmrd_cs)
               );
   assign dmem_rdata_cs = dmem_writeb[0] ? dmrd_cs : 1;

endmodule
