`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/all_branches.imem"
`define DMEM_INIT_PATH "../test/all_branches.imem"
`else
`define IMEM_INIT_PATH "test/mret.imem"
`define DMEM_INIT_PATH "test/mret.imem"
`endif
