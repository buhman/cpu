`include "dmem_encdec.vh"

(* nolatches *)
module dmem_decode
( input       [1:0] width
, input             zero_ext
, input       [1:0] addr
, input      [31:0] rdata
// output
, output reg [31:0] decode
);
   (* always_comb *)
   always @* begin
      case (width)
        `ENCDEC_ZERO: decode = 32'b0;
        `ENCDEC_BYTE:
          case (addr)
            2'b00: decode = {{24{zero_ext ? 1'b0 : rdata[7] }}, rdata[7:0]  };
            2'b01: decode = {{24{zero_ext ? 1'b0 : rdata[15]}}, rdata[15:8] };
            2'b10: decode = {{24{zero_ext ? 1'b0 : rdata[23]}}, rdata[23:16]};
            2'b11: decode = {{24{zero_ext ? 1'b0 : rdata[31]}}, rdata[31:24]};
          endcase
        `ENCDEC_HALF:
          case (addr)
            2'b00: decode = {{16{zero_ext ? 1'b0 : rdata[15]}}, rdata[15:0] };
            2'b01: decode = {{16{zero_ext ? 1'b0 : rdata[23]}}, rdata[23:8] };
            2'b10: decode = {{16{zero_ext ? 1'b0 : rdata[31]}}, rdata[31:16]};
            2'b11: decode = 32'b0;
          endcase
        `ENCDEC_WORD:
          case (addr)
            2'b00:   decode = rdata;
            default: decode = 32'b0;
          endcase
      endcase
   end
endmodule
