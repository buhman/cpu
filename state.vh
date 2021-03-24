`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/jump_misalign.imem"
`define DMEM_INIT_PATH "../test/jump_misalign.imem"
`else
`define IMEM_INIT_PATH "test/mret.imem"
`define DMEM_INIT_PATH "test/mret.imem"
`endif
