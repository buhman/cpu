`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/trap.imem"
`define DMEM_INIT_PATH "../test/trap.imem"
`else
`define IMEM_INIT_PATH "test/trap.imem"
`define DMEM_INIT_PATH "test/trap.imem"
`endif
