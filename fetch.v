module fetch
( input             clk
, input             data_hazard
, input      [31:0] mb_if__jump_target
, input             mb_if__branch_taken
, input             mb_if__trap_taken
, input             mb_if__predict_taken
, input      [31:0] mb_if__predict_target
, input      [31:0] mb_if__pc
, input      [31:0] mb_if__pc_4
// output
, output reg        pipe_flush = 1
, output reg [31:0] if_id__pc
, output reg [31:0] if_id__ins
, output reg        if_id__predict_taken
, output reg [31:0] if_id__predict_target
, output            if_id__data_hazard
, output            if_id__instret
);
   wire [31:0] ins;
   reg  [31:0] pc = 32'h00000040;
   wire [31:0] pc4 = pc + 4;
   wire [31:0] next_pc;

   reg  bubble = 0;
   wire no_hazard = bubble || !data_hazard;

   wire read_next_pc = pipe_flush || mispredict || no_hazard;

   imem if_imem ( .clk(!clk)
                , .addr(pc[9:2])
                , .read(read_next_pc)
                // output
                , .data(ins)
                );

   wire [31:0] predict_target;
   wire        predict_taken;

   wire [31:0] btb_pc = data_hazard ? if_id__pc : pc;

   btb if_btb ( .clk(clk)
              , .update_pc(mb_if__pc)
              , .update_target(mb_if__jump_target)
              , .update_taken(mb_if__branch_taken)

              , .pc(btb_pc)

              // output
              , .predict_target(predict_target)
              , .predict_taken(predict_taken)
              );

   wire        branch_taken = !pipe_flush && mb_if__branch_taken;
   wire        trap_taken = !pipe_flush && mb_if__trap_taken;

   wire        predict_target_neq = mb_if__predict_target != mb_if__jump_target;
   wire        predict_taken_neq = mb_if__branch_taken != mb_if__predict_taken;

   wire        mispredict = !pipe_flush && (predict_taken_neq || (mb_if__branch_taken && predict_target_neq));
   wire [31:0] mispredict_target = mb_if__branch_taken ? mb_if__jump_target : mb_if__pc_4;


   assign next_pc = trap_taken ? mb_if__jump_target :
                    mispredict ? mispredict_target :
                    predict_taken ? predict_target :
                    pc4;

   wire        data_hazard_next = !pipe_flush && data_hazard && !no_hazard;
   assign if_id__data_hazard = data_hazard_next;
   assign if_id__instret = !data_hazard_next;

   always @(posedge clk) begin
      if (read_next_pc) begin
         if_id__pc <= pc;
         pc <= next_pc;
      end

      bubble <= !pipe_flush && data_hazard && !bubble;

      if_id__ins <= ins;

      pipe_flush <= (mispredict || trap_taken);

      if_id__predict_taken <= predict_taken;
      if_id__predict_target <= predict_target;
   end

endmodule
