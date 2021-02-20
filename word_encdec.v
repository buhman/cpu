`include "include.v"

module word_encdec(input [2:0]       funct3,
                   input [1:0]       addr,
                   input [31:0]      rdata,
                   input [31:0]      wdata,
                   output reg [31:0] decode,
                   output reg [31:0] encode,
                   output reg        unaligned,
                   input             write,
                   output [3:0]  writeb
                   );

   wire [1:0] width = funct3[1:0];
   wire       zero_ext = funct3[2];

   reg [3:0] write_bits;
   assign writeb = write ? write_bits : 4'b0000;

   always @* begin
      case (width)
        `ENCDEC_BYTE: begin
          unaligned = 0;
          case (addr)
            2'b00: begin
               decode = {{24{zero_ext ? 1'b0 : rdata[7]}}, rdata[7:0]};
               encode = {24'b0, wdata[7:0]};
               write_bits = 4'b0001;
            end
            2'b01: begin
               decode = {{24{zero_ext ? 1'b0 : rdata[15]}}, rdata[15:8]};
               encode = {16'b0, wdata[7:0], 8'b0};
               write_bits = 4'b0010;
            end
            2'b10: begin
               decode = {{24{zero_ext ? 1'b0 : rdata[23]}}, rdata[23:16]};
               encode = {8'b0, wdata[7:0], 16'b0};
               write_bits = 4'b0100;
            end
            2'b11: begin
               decode = {{24{zero_ext ? 1'b0 : rdata[31]}}, rdata[31:24]};
               encode = {wdata[7:0], 24'b0};
               write_bits = 4'b1000;
            end
          endcase
        end
        `ENCDEC_HALF:
          case (addr)
            2'b00: begin
               decode = {{16{zero_ext ? 1'b0 : rdata[15]}}, rdata[15:0]};
               encode = {16'b0, wdata[15:0]};
               write_bits = 4'b0011;
               unaligned = 0;
            end
            2'b01: begin
               decode = {{16{zero_ext ? 1'b0 : rdata[23]}}, rdata[23:8]};
               encode = {8'b0, wdata[15:0], 8'b0};
               write_bits = 4'b0110;
               unaligned = 0;
            end
            2'b10: begin
               decode = {{16{zero_ext ? 1'b0 : rdata[31]}}, rdata[31:16]};
               encode = {wdata[15:0], 16'b0};
               write_bits = 4'b1100;
               unaligned = 0;
            end
            2'b11: begin
               decode = 32'b0;
               encode = 32'b0;
               write_bits = 4'b0000;
               unaligned = 1;
            end
          endcase
        `ENCDEC_WORD: begin
          case (addr)
            2'b00: begin
               decode = rdata[31:0];
               encode = wdata[31:0];
               write_bits = 4'b1111;
               unaligned = 0;
            end
            default: begin
               decode = 32'b0;
               encode = 32'b0;
               write_bits = 4'b0000;
               unaligned = 1;
            end
          endcase // case (addr)
        end
        default: begin
           decode = 32'b0;
           encode = 32'b0;
           write_bits = 4'b0000;
           unaligned = 1;
        end
      endcase
   end
endmodule
