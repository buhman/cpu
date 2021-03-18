module hazard
( input [4:0] rs1_addr
, input [4:0] rs2_addr
, input [4:0] id_ex__rd_addr
, input       id_ex__dmem_read
// output
, output      data_hazard
);

   assign data_hazard =  id_ex__dmem_read
                     && (rs1_addr == id_ex__rd_addr || rs2_addr == id_ex__rd_addr);

endmodule
