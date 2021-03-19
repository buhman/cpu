module hazard
( input [4:0] rs1_addr
, input [4:0] rs2_addr
, input [4:0] id_ex__rd_addr
, input [1:0] id_ex__rd_src
// output
, output      data_hazard
);

   wire mem_csr = (id_ex__rd_src == `RD_SRC_DMEM_RDATA || id_ex__rd_src == `RD_SRC_CSR);

   wire rs_rd = (rs1_addr == id_ex__rd_addr || rs2_addr == id_ex__rd_addr);

   assign data_hazard = mem_csr && rs_rd;

endmodule
