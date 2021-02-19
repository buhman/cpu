module spi_slave_over
  (input             clk,
   input             sck,
   input             cs,
   input             mosi,
   output            miso,
   output reg [31:0] rdata,
   input [31:0]      wdata
   );

   reg [3:0] sck_q;
   reg [3:0] cs_q;

   reg [31:0] tx_buf;
   reg [31:0] rx_buf;

   always @(posedge clk) begin
      if (sck_q == 4'b1100) begin
         // negedge sck
         tx_buf <= {tx_buf[30:0], 1'b1};
         rx_buf <= {rx_buf[30:0], mosi};
      end
      if (cs_q == 4'b1100) begin
         // negedge cs
         tx_buf <= wdata;
         rx_buf <= {32{1'b1}};
      end
      if (cs_q == 4'b0011)
        // posedge cs
        rdata <= rx_buf;

      sck_q <= {sck_q[2:0], sck};
      cs_q <= {cs_q[2:0], cs};
   end

   assign miso = tx_buf[31];

endmodule

module spi_slave_mem (//
                      input             sck,
                      input             cs,
                      input             mosi,
                      output            miso,
                      //
                      input             clk,
                      input [3:0]       writeb,
                      input             read,
                      input [7:0]       addr,
                      input [31:0]      wdata,
                      output reg [31:0] rdata
                      );
   reg [31:0] ss_wdata = 32'h68656c6f;
   wire [31:0] ss_rdata;
   spi_slave_over sso (.clk(clk),
                       .sck(sck),
                       .cs(cs),
                       .mosi(mosi),
                       .miso(miso),
                       .wdata(ss_wdata),
                       .rdata(ss_rdata)
                       );

   wire [3:0] ss_writeb = (addr == 0) ? writeb : 4'b0000;
   wire ss_read = (addr == 1) ? read : 1'b0;

   always @(posedge clk) begin
      if (ss_writeb[0]) ss_wdata[7:0] <= wdata[7:0];
      if (ss_writeb[1]) ss_wdata[15:8] <= wdata[15:8];
      if (ss_writeb[2]) ss_wdata[23:16] <= wdata[23:16];
      if (ss_writeb[3]) ss_wdata[31:24] <= wdata[31:24];

      if (read) rdata <= ss_rdata;
   end
endmodule
