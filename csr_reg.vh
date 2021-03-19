/* verilator lint_off UNUSED */
localparam mstatus       = 12'h300;
localparam misa          = 12'h301;
localparam medeleg       = 12'h302;
localparam mideleg       = 12'h303;
localparam mie           = 12'h304;
localparam mtvec         = 12'h305;
localparam mcounteren    = 12'h306;

localparam mscratch_addr = 12'h340;
localparam mepc_addr     = 12'h341;
localparam mcause_addr   = 12'h342;
localparam mtval_addr    = 12'h343;
localparam mip_addr      = 12'h344;

localparam mcycle_addr   = 12'hb00;
localparam minstret_addr = 12'hb02;
/* verilator lint_on UNUSED */

localparam mscratch = 1;
localparam mepc     = 2;
localparam mcause   = 3;
localparam mtval    = 4;
localparam mip      = 5;
