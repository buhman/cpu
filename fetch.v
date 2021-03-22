module fetch
( input             clk
, input             data_hazard
, input      [31:0] mb_if__jump_target
, input             mb_if__branch_taken
, input             mb_if__trap_taken
, input             mb_if__predict_taken
, input      [31:0] mb_if__pc_4
// output
, output reg        pipe_flush = 1
, output reg        if_id__ins_misalign
, output reg [31:0] if_id__pc
, output reg [31:0] if_id__ins
, output reg        if_id__predict_taken
, output            if_id__data_hazard
, output            if_id__instret
);
   reg  [31:0] pc = 32'h00000040;
   wire [31:0] pc4 = pc + 4;
   wire [31:0] next_pc;

   wire        ins_misalign = (pc[1:0] != 2'b00);
   reg         bubble = 0;
   wire        no_hazard = bubble || !data_hazard;

   wire read_next_pc = pipe_flush || mispredict || no_hazard;

   wire [31:0] ins;
   imem if_imem ( .clk(!clk)
                , .addr(pc[9:2])
                , .read(read_next_pc)
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

   wire      branch_taken = !pipe_flush && mb_if__branch_taken;
   wire        trap_taken = !pipe_flush && mb_if__trap_taken;
   wire        mispredict = !pipe_flush && mb_if__branch_taken != mb_if__predict_taken;
   wire [31:0] mispredict_target = mb_if__branch_taken ? mb_if__jump_target : mb_if__pc_4;

   `define BRANCH_PREDICTION 1

   assign next_pc = trap_taken ? mb_if__jump_target :
                    `ifdef BRANCH_PREDICTION
                    mispredict ? mispredict_target :
                    align_predict_taken ? predict_target :
                    `else
                    branch_taken ? mb_if__jump_target :
                    `endif
                    pc4;

   wire        data_hazard_next = !pipe_flush && data_hazard && !no_hazard;
   assign if_id__data_hazard = data_hazard_next;
   assign if_id__instret = !data_hazard_next;

   always @(posedge clk) begin
      if_id__ins_misalign <= ins_misalign;

      if (read_next_pc) begin
         if_id__pc <= pc;
         pc <= next_pc;
      end

      bubble <= !pipe_flush && data_hazard && !bubble;

      if_id__ins <= ins;

      `ifdef BRANCH_PREDICTION
      pipe_flush <= (mispredict || trap_taken);
      `else
      pipe_flush <= (branch_taken || trap_taken);
      `endif

      if_id__predict_taken <= align_predict_taken;
   end

endmodule
