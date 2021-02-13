

module soc
   (input clk,
    output cpu_clk,
    output spi_sck,
    output pc_cs,
    output pc_mosi,
    output imem_data_cs,
    output imem_data_mosi,
    output dmem_wdata_cs,
    output dmem_wdata_mosi,
    output dmem_rdata_cs,
    output dmem_rdata_mosi
    );

   wire [31:0] imem_data;
   wire [31:0] imem_addr;
   wire        dmem_write;
   wire        dmem_read;
   wire [31:0] dmem_addr;
   wire [31:0] dmem_wdata;
   wire [31:0] dmem_rdata;
   wire [31:0] pc_out;

   wire        cpu_clk;

   cpu c (.clk(cpu_clk),
          .imem_addr(imem_addr),
          .imem_data(imem_data),
          .dmem_write(dmem_write),
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

   dmem dm (.clk(cpu_clk),
            .write(dmem_write),
            .read(dmem_read),
            .addr(dmem_addr[9:2]),
            .wdata(dmem_wdata),
            .rdata(dmem_rdata)
            );

   // debug interface

   wire        spi_sck;
   reg         cclk = 0;

   divider #(.P(100),
   //divider #(.P(0),
             .N(7)) sc (.clk_in(clk),
                        .clk_out(spi_sck)
                        );

   always @(negedge spi_sck)
     // cclk is roughly 1/33 of spi_sck
     cclk <= (pc_cs && !cclk);
   assign cpu_clk = cclk;

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
   assign dmem_wdata_cs = dmem_write ? dmwd_cs : 1;

   wire        dmrd_cs;
   spi dmrd_s (.data(dmem_rdata),
               .sck(spi_sck),
               .mosi(dmem_rdata_mosi),
               .cs(dmrd_cs)
               );
   assign dmem_rdata_cs = dmem_read ? dmrd_cs : 1;

endmodule
