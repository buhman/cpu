`define OP_LOAD     5'b00000
`define OP_STORE    5'b01000
`define OP_BRANCH   5'b11000
`define OP_AUIPC    5'b00101
`define OP_LUI      5'b01101
`define OP_OP_IMM   5'b00100
`define OP_OP       5'b01100
`define OP_JALR     5'b11001
`define OP_JAL      5'b11011
`define OP_SYSTEM   5'b11100
`define OP_MISC_MEM 5'b00011

`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111

`define FUNCT3_ADD  3'b000
`define FUNCT3_SLL  3'b001
`define FUNCT3_SLT  3'b010
`define FUNCT3_SLTU 3'b011
`define FUNCT3_XOR  3'b100
`define FUNCT3_SRL  3'b101
`define FUNCT3_OR   3'b110
`define FUNCT3_AND  3'b111

`define FUNCT3_LB  3'b000
`define FUNCT3_LH  3'b001
`define FUNCT3_LW  3'b010
`define FUNCT3_LBU 3'b100
`define FUNCT3_LHU 3'b101

`define FUNCT3_SB  3'b000
`define FUNCT3_SH  3'b001
`define FUNCT3_SW  3'b010

`define FUNCT7_ZERO 7'b0000000
`define FUNCT7_ALT  7'b0100000

`define FUNCT3_FENCE 3'b000

`define FUNCT12_ECALL  12'd0
`define FUNCT12_EBREAK 12'd1

`define IMM_I_TYPE 3'd0
`define IMM_S_TYPE 3'd1
`define IMM_B_TYPE 3'd2
`define IMM_U_TYPE 3'd3
`define IMM_J_TYPE 3'd4
`define IMM_NONE_TYPE 3'd5
