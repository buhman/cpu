`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/forward_csr.imem"
`define DMEM_INIT_PATH "../test/forward_csr.imem"
`else
`define IMEM_INIT_PATH "test/forward_csr.imem"
`define DMEM_INIT_PATH "test/forward_csr.imem"
`endif
