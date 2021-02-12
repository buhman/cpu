module spi (input [31:0] data,
            //input      data_ready,
            //output     data_sent,
            output reg mosi,
            input      sck,
            output reg cs
            );

   parameter STATE_IDLE = 2'd0;
   parameter STATE_TX = 2'd1;

   reg [31:0]  tx_buf;
   reg [5:0]   tx_ix;
   reg         state = STATE_IDLE;

   assign data_sent = (state != STATE_TX);

   always @(posedge sck) begin
      if (state == STATE_IDLE && data_ready)
        begin
           tx_buf <= data;
           tx_ix <= 6'd31;
           state <= STATE_TX;
        end
      if (state == STATE_TX)
        if (tx_ix == 6'd0)
          state <= STATE_IDLE;
        else
          tx_ix <= tx_ix - 1;
   end

   always @* begin
      if (state == STATE_TX)
        begin
           cs = 1'b0;
           //$display("%t bit %d", $time, tx_ix);
           mosi = tx_buf[tx_ix];
        end
      else
        begin
           cs = 1'b1;
           mosi = 1'b0;
        end
   end

   reg data_ready = 0;
   wire data_sent;
   always @ (posedge sck)
     data_ready <= (!data_ready && data_sent);
endmodule
