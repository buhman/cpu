module uart (input       clk,
             input [7:0] wdata,
             input       wdata_ready,
             output      stop,
             output      tx
             );

   parameter STATE_STOP = 2'd0;
   parameter STATE_START = 2'd1;
   parameter STATE_TX_BUF = 2'd2;

   reg [7:0] tx_buf;
   reg [3:0] tx_bits;
   reg [1:0] state = STATE_STOP;
   reg [1:0] tx_bytes;

   wire start;
   assign stop = (state == STATE_STOP);
   assign start = (state == STATE_START);

   assign tx = stop ? 1'b1 : start ? 1'b0 : tx_buf[0];

   always @(posedge clk) begin
      case (state)
        STATE_STOP: begin
           if (wdata_ready)
              state <= STATE_START;
        end
        STATE_START: begin
           tx_buf <= wdata;
           tx_bits <= 0;
           state <= STATE_TX_BUF;
        end
        STATE_TX_BUF: begin
           tx_buf <= {1'b1, tx_buf[7:1]};
           tx_bits <= tx_bits + 1;

           if (tx_bits == 4'd7)
             state <= STATE_STOP;
        end
      endcase
   end
endmodule

module uart32 (input        clk,
               output       tx,
               //
               input [31:0] wdata,
               input        wdata_ready,
               output       stop
               );

   wire [7:0] uart_wdata;
   wire       uart_stop;
   wire       uart_ready = state != 0;
   reg [31:0] tx_buf;

   reg        ready_state = 0;

   uart u (.clk(clk),
           .wdata(uart_wdata),
           .wdata_ready(uart_ready),
           .stop(uart_stop),
           .tx(tx)
           );

   reg [2:0] tx_ix;
   assign uart_wdata = tx_buf[31:24];
   //assign stop = (state == 0);
   assign stop = uart_stop;

   reg [1:0] state = 0;

   always @(posedge clk)
     case (state)
       0: begin
          if (wdata_ready == ready_state && uart_stop) begin
             tx_buf <= wdata;
             tx_ix <= 0;
             state <= state + 1;
             ready_state <= ~ready_state;
          end
       end
       1: begin
          if (tx_ix == 4)
            state <= 0;
          if (uart_stop)
            state <= state + 1;
       end
       2: begin
          tx_buf <= {tx_buf[23:0], 8'd0};
          tx_ix <= tx_ix + 1;
          state <= 1;
       end
     endcase
endmodule

module uart_mem (//
                 input             uart_clk,
                 output            tx,
                 //
                 input             cpu_clk,
                 input [3:0]       writeb,
                 input             read,
                 input [5:0]       addr,
                 input [31:0]      wdata,
                 output reg [31:0] rdata
                 );
   reg wdata_state = 0;
   reg [31:0] uart_wdata = 32'h68656c6f;
   wire uart_stop;

   uart32 u32 (.clk(uart_clk),
               .tx(tx),
               //
               .wdata(uart_wdata),
               .wdata_ready(wdata_state),
               .stop(uart_stop)
               );

   wire [3:0] uart_writeb = (addr == 0) ? writeb : 4'b0000;
   //wire uart_read = (addr == 1) ? read : 1'b0;

   always @(posedge cpu_clk) begin
      if (uart_writeb[0])
        $display("%t uart_write addr:%h wdata:%h %d %d", $time, addr, wdata, read, writeb[0]);

      if (uart_writeb[0]) uart_wdata[7:0] <= wdata[7:0];
      if (uart_writeb[1]) uart_wdata[15:8] <= wdata[15:8];
      if (uart_writeb[2]) uart_wdata[23:16] <= wdata[23:16];
      if (uart_writeb[3]) uart_wdata[31:24] <= wdata[31:24];
      if (uart_writeb[0]) wdata_state <= ~wdata_state;

      //if (read) rdata <= uart_rdata;
   end
endmodule
