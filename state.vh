`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/forward.imem"
`define DMEM_INIT_PATH "../test/forward.imem"
`else
`define IMEM_INIT_PATH "test/forward.imem"
`define DMEM_INIT_PATH "test/forward.imem"
`endif
