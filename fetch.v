module fetch
( input             clk
, input             data_hazard
, input      [31:0] mb_if__jump_target
, input             mb_if__jump_taken
// output
, output reg        if_id__ins_misalign
, output reg [31:0] if_id__pc
, output     [31:0] if_id__ins
, output reg        pipe_flush = 1
);
   reg  [31:0] pc = 32'h00000040;
   wire [31:0] pc4 = pc + 4;
   wire [31:0] next_pc;

   wire        ins_misalign = (pc[1:0] != 2'b00);

   wire        jump_taken = pipe_flush ? 1'b0 : mb_if__jump_taken;
   wire        no_hazard = !data_hazard;

   imem if_imem ( .clk(clk)
                , .addr(pc[9:2])
                , .read(no_hazard)
                // output
                , .data(if_id__ins)
                );

   assign next_pc = jump_taken ? mb_if__jump_target : pc4;

   always @(posedge clk) begin
      if_id__ins_misalign <= ins_misalign;

      if (no_hazard) begin
         if_id__pc <= pc;
         pc <= next_pc;
      end

      pipe_flush <= jump_taken;
   end

endmodule
