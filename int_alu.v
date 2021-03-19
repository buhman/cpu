`include "int_alu.vh"

/* verilator lint_off UNOPTFLAT */

/*
 ice40: 623 LUT4 , 659 LC    , 15.41ns
 ecp5:  957 LUT4 , 513 SLICE , 13.85ns
 */
(* nolatches *)
module int_alu
(
  input      [ 3:0] op
, input      [31:0] a
, input      [31:0] b
, output reg [31:0] y
, output 	    zero
);
   /* left shift ; 158 LC , 10.74ns */
   wire [31:0] sl_stage [0:4];
   assign sl_stage[0] = b[0] ? {          a[30:0], { 1{1'b0}}} : a;
   assign sl_stage[1] = b[1] ? {sl_stage[0][29:0], { 2{1'b0}}} : sl_stage[0];
   assign sl_stage[2] = b[2] ? {sl_stage[1][27:0], { 4{1'b0}}} : sl_stage[1];
   assign sl_stage[3] = b[3] ? {sl_stage[2][23:0], { 8{1'b0}}} : sl_stage[2];
   assign sl_stage[4] = b[4] ? {sl_stage[3][15:0], {16{1'b0}}} : sl_stage[3];
   /*
    interestingly, sl_stage appears to be equivalent/identical to what the
    `<<` verilog operator synthesizes to.
    */

   /* right shift ; 166 LC , 11.13ns */
   wire [31:0] sr_stage [0:4];
   wire sr_fill = (op == `ALU_SRA) ? a[31] : 1'b0;
   assign sr_stage[0] = b[0] ? {{ 1{sr_fill}},           a[31:1 ]} : a;
   assign sr_stage[1] = b[1] ? {{ 2{sr_fill}}, sr_stage[0][31:2 ]} : sr_stage[0];
   assign sr_stage[2] = b[2] ? {{ 4{sr_fill}}, sr_stage[1][31:4 ]} : sr_stage[1];
   assign sr_stage[3] = b[3] ? {{ 8{sr_fill}}, sr_stage[2][31:8 ]} : sr_stage[2];
   assign sr_stage[4] = b[4] ? {{16{sr_fill}}, sr_stage[3][31:16]} : sr_stage[3];

   /*
    sr_stage appears to be slightly different from what

      (op == `ALU_SRA) ? $signed(a) >>> b[4:0] : $signed(a) >> b[4:0]

    synthesizes to. I think these shifters are cool written out like this, and
    not harmful, so I'll keep this as written.
    */

   wire [31:0]  add = a + b;  //  35 LC , 10.12ns
   wire [31:0]  sub = $signed(a) - $signed(b);
   wire	         lt = $signed(a) < $signed(b);  // 100 LC , 11.32ns
   wire	        ltu = a < b;  // 100 LC , 11.32ns
   wire [31:0] xor_ = a ^ b; //  34 LC ,  4.25ns
   wire [31:0]  or_ = a | b;  //  34 LC ,  4.25ns
   wire [31:0] and_ = a & b; //  34 LC ,  4.25ns

   (* always_comb *)
   always @*
     case (op)
       `ALU_ADD           : y = add;
       `ALU_SUB           : y = sub;
       `ALU_SLL           : y = sl_stage[4];
       `ALU_SRL, `ALU_SRA : y = sr_stage[4];
       `ALU_LT            : y = {31'd0, lt};
       `ALU_LTU           : y = {31'd0, ltu};
       `ALU_XOR           : y = xor_;
       `ALU_OR            : y = or_;
       `ALU_AND           : y = and_;
       default            : y = 32'h0;
     endcase

   assign zero = (y == 0);

endmodule
