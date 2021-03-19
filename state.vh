`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/fib.imem"
`define DMEM_INIT_PATH "../test/fib.imem"
`else
`define IMEM_INIT_PATH "test/fib.imem"
`define DMEM_INIT_PATH "test/fib.imem"
`endif
