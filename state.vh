`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/external_int.imem"
`define DMEM_INIT_PATH "../test/external_int.imem"
`else
`define IMEM_INIT_PATH "test/external_int.imem"
`define DMEM_INIT_PATH "test/external_int.imem"
`endif
