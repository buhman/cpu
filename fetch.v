module fetch
( input             clk
, input             data_hazard
, input      [31:0] mb_if__jump_target
, input             mb_if__branch_taken
, input             mb_if__trap_taken
, input             mb_if__predict_taken
// output
, output reg        pipe_flush = 1
, output reg        if_id__ins_misalign
, output reg [31:0] if_id__pc
, output reg [31:0] if_id__ins
, output reg        if_id__predict_taken
);
   reg  [31:0] pc = 32'h00000040;
   wire [31:0] pc4 = pc + 4;
   wire [31:0] next_pc;

   wire        ins_misalign = (pc[1:0] != 2'b00);

   wire        branch_taken = pipe_flush ? 1'b0 : mb_if__branch_taken;
   wire        no_hazard = !data_hazard;

   wire [31:0] ins;
   imem if_imem ( .clk(!clk)
                , .addr(pc[9:2])
                , .read(no_hazard)
                // output
                , .data(ins)
                );

   wire [31:0] predict_target;
   wire        predict_taken;
   wire        align_predict_taken = (!ins_misalign && predict_taken);

   branch_predict if_branch_predict ( .pc(pc)
                                    , .ins(ins)
                                    // output
                                    , .target(predict_target)
                                    , .taken(predict_taken)
                                    );

   wire        mispredict = branch_taken != mb_if__predict_taken;
   wire [31:0] mispredict_target = branch_taken ? mb_if__jump_target : pc4;

   assign next_pc = mb_if__trap_taken ? mb_if__jump_target :
                    mispredict ? mispredict_target :
                    align_predict_taken ? predict_target :
                    pc4;

   always @(posedge clk) begin
      if_id__ins_misalign <= ins_misalign;

      if (no_hazard) begin
         if_id__pc <= pc;
         pc <= next_pc;
      end
      if_id__ins <= ins;

      pipe_flush <= (mispredict || mb_if__trap_taken);

      if_id__predict_taken <= align_predict_taken;
   end

endmodule
