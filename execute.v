`include "execute.vh"
`include "control.vh"

(* nolatches *)
module execute
( input         clk
, input         pipe_flush
, input         data_hazard // csr performance counters

, input  [31:0] id_ex__rs1_rdata
, input  [31:0] id_ex__rs2_rdata
, input  [31:0] id_ex__imm
, input  [31:0] id_ex__pc
, input   [1:0] id_ex__alu_a_src
, input         id_ex__alu_b_src
, input   [3:0] id_ex__alu_op
// forwarding unit
, input   [4:0] id_ex__rs1_addr
, input   [4:0] id_ex__rs2_addr
, input   [4:0] ex_mb__rd_addr
, input   [4:0] mb_wb__rd_addr
, input         ex_mb__rd_wen
, input         mb_wb__rd_wen
, input  [31:0] wb_id__rd_wdata
// control and status register unit
, input  [11:0] id_ex__csr_addr
, input   [1:0] id_ex__csr_op
, input         id_ex__csr_src

, input         mb_if__trap_taken
, input   [4:0] mb_ex__trap_src
, input  [31:0] mb_ex__dmem_addr

, input         mb_ex__instret
// arithmetic-logic unit output
, output reg [31:0] ex_mb__alu_y
, output reg [31:0] ex_mb__pc
, output reg [31:0] ex_mb__pc_4
// forwarding unit output
, output reg [31:0] ex_mb__rs1_rdata
, output reg [31:0] ex_mb__rs2_rdata
// control and status register unit output
, output     [31:0] ex_mb__csr_rdata
, output     [31:0] ex_mb__mtvec_rdata
, output     [31:0] ex_mb__mepc_rdata
);
   /* forwarding unit */

   wire forward_ex_mb = ((ex_mb__rd_addr != 5'd0) && ex_mb__rd_wen);
   wire forward_mb_wb = ((mb_wb__rd_addr != 5'd0) && mb_wb__rd_wen);
   wire rs1_forward_ex_mb = (forward_ex_mb && id_ex__rs1_addr == ex_mb__rd_addr);
   wire rs2_forward_ex_mb = (forward_ex_mb && id_ex__rs2_addr == ex_mb__rd_addr);
   wire rs1_forward_mb_wb = (forward_mb_wb && id_ex__rs1_addr == mb_wb__rd_addr);
   wire rs2_forward_mb_wb = (forward_mb_wb && id_ex__rs2_addr == mb_wb__rd_addr);

   wire [31:0] rs1_rdata = rs1_forward_ex_mb ? ex_mb__alu_y :
                           rs1_forward_mb_wb ? wb_id__rd_wdata :
                           id_ex__rs1_rdata;

   wire [31:0] rs2_rdata = rs2_forward_ex_mb ? ex_mb__alu_y :
                           rs2_forward_mb_wb ? wb_id__rd_wdata :
                           id_ex__rs2_rdata;

   (* always_comb *)
   always @*
     case (id_ex__alu_a_src)
       `ALU_A_ZERO : alu_a = 32'd0;
       `ALU_A_PC   : alu_a = id_ex__pc;
       `ALU_A_RS1  : alu_a = rs1_rdata;
       default     : alu_a = 32'hffffffff;
     endcase

   (* always_comb *)
   always @*
     case (id_ex__alu_b_src)
       `ALU_B_IMM : alu_b = id_ex__imm;
       `ALU_B_RS2 : alu_b = rs2_rdata;
     endcase

   /* arithmetic-logic unit */

   reg  [31:0] alu_a;
   reg  [31:0] alu_b;
   wire [31:0] alu_y;

   int_alu ex_int_alu ( .op(id_ex__alu_op)
                      , .a(alu_a)
                      , .b(alu_b)
                      , .y(alu_y)
                      );

   wire [31:0] pc_4 = id_ex__pc + 4;

   always @(posedge clk) begin
      ex_mb__alu_y <= alu_y;
      ex_mb__pc <= pipe_flush ? 32'hffffffff : id_ex__pc;
      ex_mb__pc_4 <= pipe_flush ? 32'hffffffff : pc_4;

      ex_mb__rs1_rdata <= rs1_rdata;
      ex_mb__rs2_rdata <= rs2_rdata;
   end

   /* control and status register unit */

   wire [31:0] csr_wdata = (id_ex__csr_src == `CSR_SRC_RS1) ? rs1_rdata :
                            id_ex__imm;

   csr_reg ex_csr_reg ( .clk(clk)
                      , .addr(id_ex__csr_addr)
                      , .op(id_ex__csr_op)
                      , .wdata(csr_wdata)
                      // trap state
                      , .pc(id_ex__pc)
                      , .trap(mb_if__trap_taken)
                      , .trap_src(mb_ex__trap_src)
                      , .dmem_addr(mb_ex__dmem_addr)
                      , .pipe_flush(pipe_flush)
                      // counters
                      , .instret(mb_ex__instret)
                      // output
                      , .rdata(ex_mb__csr_rdata)

                      , .mtvec_rdata(ex_mb__mtvec_rdata)
                      , .mepc_rdata(ex_mb__mepc_rdata)
                      );
endmodule
