`include "dmem_encdec.vh"

(* nolatches *)
module dmem_encode
( input       [1:0] width
, input       [1:0] addr
, input             write
, input      [31:0] wdata
// output
, output      [3:0] writeb
, output reg [31:0] encode
);
   reg [3:0] write_bits;

   (* always_comb *)
   always @* begin
      case (width)
        `ENCDEC_ZERO: begin
           write_bits = 4'b0000;
           encode = 32'b0;
        end
        `ENCDEC_BYTE:
          case (addr)
            2'b00: begin
               write_bits = 4'b0001;
               encode = {24'b0, wdata[7:0]};
            end
            2'b01: begin
               write_bits = 4'b0010;
               encode = {16'b0, wdata[7:0], 8'b0};
            end
            2'b10: begin
               write_bits = 4'b0100;
               encode = {8'b0, wdata[7:0], 16'b0};
            end
            2'b11: begin
               write_bits = 4'b1000;
               encode = {wdata[7:0], 24'b0};
            end
          endcase
        `ENCDEC_HALF:
          case (addr)
            2'b00: begin
               write_bits = 4'b0011;
               encode = {16'b0, wdata[15:0]};
            end
            2'b01: begin
               write_bits = 4'b0110;
               encode = {8'b0, wdata[15:0], 8'b0};
            end
            2'b10: begin
               write_bits = 4'b1100;
               encode = {wdata[15:0], 16'b0};
            end
            2'b11: begin
               write_bits = 4'b0000;
               encode = 32'b0;
            end
          endcase
        `ENCDEC_WORD:
          case (addr)
            2'b00: begin
               write_bits = 4'b1111;
               encode = wdata;
            end
            default: begin
               write_bits = 4'b0000;
               encode = 32'b0;
            end
          endcase
      endcase
   end

   assign writeb = write ? write_bits : 4'b0000;
endmodule
