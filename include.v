`define IMM_R_TYPE 3'd1
`define IMM_I_TYPE 3'd1
`define IMM_S_TYPE 3'd2
`define IMM_B_TYPE 3'd3
`define IMM_U_TYPE 3'd4
`define IMM_J_TYPE 3'd5

`define ALU_ADD  3'b000
`define ALU_SLL  3'b001
`define ALU_SLT  3'b010
`define ALU_SLTU 3'b011
`define ALU_XOR  3'b100
`define ALU_SRL  3'b101
`define ALU_OR   3'b110
`define ALU_AND  3'b111

`define ALU_MUL    3'b000
`define ALU_MULH   3'b001
`define ALU_MULHSU 3'b010
`define ALU_MULHU  3'b011
`define ALU_DIV    3'b100
`define ALU_DIVU   3'b101
`define ALU_REM    3'b110
`define ALU_REMU   3'b111

`define FUNCT3_BEQ 3'b000
`define FUNCT3_BNE 3'b001
`define FUNCT3_BLT 3'b100
`define FUNCT3_BGE 3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111

`define ENCDEC_BYTE 2'b00
`define ENCDEC_HALF 2'b01
`define ENCDEC_WORD 2'b10

`define INS_LOAD   5'b00000
`define INS_STORE  5'b01000
`define INS_BRANCH 5'b11000
`define INS_AUIPC  5'b00101
`define INS_LUI    5'b01101
`define INS_OP_IMM 5'b00100
`define INS_OP     5'b01100
`define INS_JALR   5'b11001
`define INS_JAL    5'b11011
`define INS_SYSTEM 5'b11100

`define FUNCT3_CSRRW 3'b001
`define FUNCT3_CSRRS 3'b010
`define FUNCT3_CSRRC 3'b011
`define FUNCT3_CSRRWI 3'b101
`define FUNCT3_CSRRSI 3'b110
`define FUNCT3_CSRRCI 3'b111

`define PC_IMM_0 3'b000
`define PC_IMM_4 3'b001
`define PC_IMM_BNZ 3'b010
`define PC_IMM_BZ 3'b011
`define PC_IMM_JAL 3'b100
`define PC_IMM_JALR 3'b101

`define IMEM_INIT_PATH "../cpu2/test/fib.imem"
`define DMEM_INIT_PATH "../aoc2020/day5/input.dmem"

//`define ENABLE_MUL 1
