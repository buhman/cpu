`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/branch.imem"
`define DMEM_INIT_PATH "../test/branch.imem"
`else
`define IMEM_INIT_PATH "test/branch.imem"
`define DMEM_INIT_PATH "test/branch.imem"
`endif
