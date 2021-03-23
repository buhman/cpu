`ifdef VERILATOR
`define IMEM_INIT_PATH "../test/predict_jalr.imem"
`define DMEM_INIT_PATH "../test/predict_jalr.imem"
`else
`define IMEM_INIT_PATH "test/mret.imem"
`define DMEM_INIT_PATH "test/mret.imem"
`endif
