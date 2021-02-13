`include "include.v"

module word_decode(input [2:0]       funct3,
                   input [1:0]       addr,
                   input [31:0]      data,
                   output reg [31:0] decode,
                   output reg        unaligned
                   );

   wire [1:0] width = funct3[1:0];
   wire       zero_ext = funct3[2];

   always @* begin
      case (width)
        `ENCDEC_BYTE: begin
          unaligned = 0;
          case (addr)
            2'b00: decode = {{24{zero_ext ? 1'b0 : data[7]}}, data[7:0]};
            2'b01: decode = {{24{zero_ext ? 1'b0 : data[15]}}, data[15:8]};
            2'b10: decode = {{24{zero_ext ? 1'b0 : data[23]}}, data[23:16]};
            2'b11: decode = {{24{zero_ext ? 1'b0 : data[31]}}, data[31:24]};
          endcase
        end
        `ENCDEC_HALF:
          case (addr)
            2'b00: begin
               decode = {{16{zero_ext ? 1'b0 : data[15]}}, data[15:0]};
               unaligned = 0;
            end
            2'b01: begin
               decode = {{16{zero_ext ? 1'b0 : data[23]}}, data[23:8]};
               unaligned = 0;
            end
            2'b10: begin
               decode = {{16{zero_ext ? 1'b0 : data[31]}}, data[31:16]};
               unaligned = 0;
            end
            2'b11: begin
               decode = 32'b0;
               unaligned = 1;
            end
          endcase
        `ENCDEC_WORD:
          case (addr)
            2'b00: begin
               decode = data;
               unaligned = 0;
            end
            default: begin
               decode = 32'b0;
               unaligned = 1;
            end
          endcase // case (addr)
        default: begin
           decode = 32'b0;
           unaligned = 1;
        end
      endcase
   end
endmodule
