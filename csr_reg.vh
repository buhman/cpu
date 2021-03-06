/* verilator lint_off UNUSED */
localparam mstatus_addr  = 12'h300;
localparam misa_addr     = 12'h301;
localparam medeleg_addr  = 12'h302;
localparam mideleg_addr  = 12'h303;
localparam mie_addr      = 12'h304;
localparam mtvec_addr    = 12'h305;
localparam mcounteren_addr = 12'h306;

localparam mscratch_addr = 12'h340;
localparam mepc_addr     = 12'h341;
localparam mcause_addr   = 12'h342;
localparam mtval_addr    = 12'h343;
localparam mip_addr      = 12'h344;

localparam mcycle_addr   = 12'hb00;
localparam minstret_addr = 12'hb02;
/* verilator lint_on UNUSED */

localparam mtvec    = 1;
localparam mepc     = 2;

localparam mcause   = 3;
localparam mtval    = 4;

`define ENABLE_COUNTERS 1
`ifdef ENABLE_COUNTERS
localparam mcycle   = 5;
localparam minstret = 6;
`define CSR_LAST 6
`else
`define CSR_LAST 4
`endif
