`include "jump.vh"
`include "control.vh"

module decode
( input              clk
, input              pipe_flush

, input              if_id__ins_misalign
, input       [31:0] if_id__ins

, input       [31:0] if_id__pc

// falling-edge register writeback input
, input              wb_id__rd_wen
, input       [31:0] wb_id__rd_wdata
, input        [4:0] wb_id__rd_addr

// output
, output reg         id_ex__ins_misalign
, output reg         id_ex__ins_illegal
, output reg         id_ex__ecall
, output reg         id_ex__ebreak

, output reg  [31:0] id_ex__pc

, output reg  [31:0] id_ex__imm
, output wire [31:0] id_ex__rs1_rdata
, output wire [31:0] id_ex__rs2_rdata
, output reg   [4:0] id_ex__rs1_addr
, output reg   [4:0] id_ex__rs2_addr

, output reg   [3:0] id_ex__alu_op
, output reg   [1:0] id_ex__alu_a_src
, output reg         id_ex__alu_b_src

, output reg   [1:0] id_ex__dmem_width
, output reg         id_ex__dmem_zero_ext
, output reg         id_ex__dmem_read
, output reg         id_ex__dmem_write

, output reg         id_ex__jump_base_src
, output reg   [1:0] id_ex__jump_cond

, output reg         id_ex__rd_wen
, output reg   [1:0] id_ex__rd_src
, output reg   [4:0] id_ex__rd_addr

, output reg  [11:0] id_ex__csr_addr
, output reg   [1:0] id_ex__csr_op
, output reg         id_ex__csr_src

, output             data_hazard
);
   wire  [4:0] rs1_addr;
   wire  [4:0] rs2_addr;

   wire        ins_illegal;

   wire [31:0] imm;
   wire  [3:0] alu_op;
   wire  [1:0] alu_a_src;
   wire        alu_b_src;
   wire  [1:0] dmem_width;
   wire        dmem_zero_ext;
   wire        dmem_read;
   wire        dmem_write;
   wire        jump_base_src;
   wire  [1:0] jump_cond;
   wire        rd_wen;
   wire  [1:0] rd_src;
   wire  [4:0] rd_addr;

   wire [11:0] csr_addr;
   wire  [1:0] csr_op;
   wire        csr_src;

   wire        ecall;
   wire        ebreak;

   control id_control ( .ins(if_id__ins)
                      // output
                      , .ins_illegal(ins_illegal)
                      , .imm(imm)
                      , .rs1_addr(rs1_addr)
                      , .rs2_addr(rs2_addr)

                      , .alu_op(alu_op)
                      , .alu_a_src(alu_a_src)
                      , .alu_b_src(alu_b_src)

                      , .dmem_width(dmem_width)
                      , .dmem_zero_ext(dmem_zero_ext)
                      , .dmem_read(dmem_read)
                      , .dmem_write(dmem_write)

                      , .jump_base_src(jump_base_src)
                      , .jump_cond(jump_cond)

                      , .rd_wen(rd_wen)
                      , .rd_src(rd_src)
                      , .rd_addr(rd_addr)

                      , .csr_addr(csr_addr)
                      , .csr_op(csr_op)
                      , .csr_src(csr_src)

                      , .ecall(ecall)
                      , .ebreak(ebreak)
                      );

   hazard id_hazard ( .rs1_addr(rs1_addr)
                    , .rs2_addr(rs2_addr)
                    , .id_ex__rd_addr(id_ex__rd_addr)
                    , .id_ex__rd_src(id_ex__rd_src)
                    // output
                    , .data_hazard(data_hazard)
                    );

   wire [31:0] rs1_rdata;
   wire [31:0] rs2_rdata;

   int_reg id_int_reg ( .clk(clk)
                      , .rd_wen(wb_id__rd_wen)
                      , .rd_addr(wb_id__rd_addr)
                      , .rs1_addr(rs1_addr)
                      , .rs2_addr(rs2_addr)
                      , .rd_wdata(wb_id__rd_wdata)
                      // output
                      , .rs1_rdata(rs1_rdata)
                      , .rs2_rdata(rs2_rdata)
                      );

   assign id_ex__rs1_rdata = rs1_rdata;
   assign id_ex__rs2_rdata = rs2_rdata;

   wire bubble = pipe_flush || data_hazard;

   always @(posedge clk) begin
      id_ex__ins_misalign <= bubble ? 1'b0 : if_id__ins_misalign;
      id_ex__ins_illegal  <= bubble ? 1'b0 : if_id__ins_misalign ? 1'b0 : ins_illegal;
      id_ex__ecall        <= bubble ? 1'b0 : ecall;
      id_ex__ebreak       <= bubble ? 1'b0 : ebreak;

      id_ex__pc <= bubble ? 32'hffffffff : if_id__pc;

      id_ex__imm <= imm;
      id_ex__rs1_addr <= rs1_addr;
      id_ex__rs2_addr <= rs2_addr;

      id_ex__alu_op <= alu_op;
      id_ex__alu_a_src <= alu_a_src;
      id_ex__alu_b_src <= alu_b_src;

      id_ex__dmem_width <= dmem_width;
      id_ex__dmem_zero_ext <= dmem_zero_ext;
      id_ex__dmem_read <= bubble ? 1'b0 : dmem_read;
      id_ex__dmem_write <= bubble ? 1'b0 : dmem_write;

      id_ex__jump_base_src <= jump_base_src;
      id_ex__jump_cond <= bubble ? `COND_NEVER : jump_cond;

      id_ex__rd_wen <= bubble ? 1'b0 : rd_wen;
      id_ex__rd_src <= rd_src;
      id_ex__rd_addr <= rd_addr;

      id_ex__csr_addr <= csr_addr;
      id_ex__csr_op <= bubble ? `CSR_NOP : csr_op;
      id_ex__csr_src <= csr_src;
   end

endmodule
