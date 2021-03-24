`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/csr_hazard.imem"
`define DMEM_INIT_PATH "../test/csr_hazard.imem"
`else
`define IMEM_INIT_PATH "test/mret.imem"
`define DMEM_INIT_PATH "test/mret.imem"
`endif
