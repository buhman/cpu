`define BASE_SRC_RS1 1'b0
`define BASE_SRC_PC  1'b1

`define COND_NEVER 2'd0
`define COND_ALWAYS 2'd1
`define COND_EQ_ZERO 2'd2
`define COND_NEQ_ZERO 2'd3

// trap control

`define TRAP_M_SOFT_INT       {1'b1, 4'd3 }
`define TRAP_M_TIMER_INT      {1'b1, 4'd7 }
`define TRAP_M_EXT_INT        {1'b1, 4'd11}

`define TRAP_INS_MISALIGN     {1'b0, 4'd0 }
`define TRAP_INS_ILLEGAL      {1'b0, 4'd2 }
`define TRAP_BREAK            {1'b0, 4'd3 }
`define TRAP_LOAD_MISALIGN    {1'b0, 4'd4 }
`define TRAP_STORE_MISALIGN   {1'b0, 4'd6 }
`define TRAP_M_ECALL          {1'b0, 4'd11}
