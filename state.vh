`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/forward_dmem.imem"
`define DMEM_INIT_PATH "../test/forward_dmem.imem"
`else
`define IMEM_INIT_PATH "test/forward_dmem.imem"
`define DMEM_INIT_PATH "test/forward_dmem.imem"
`endif
