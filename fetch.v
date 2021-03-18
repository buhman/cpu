module fetch
( input             clk
, input             data_hazard
, input      [31:0] mb_if__jump_target
, input             mb_if__jump_taken
// output
, output reg [31:0] if_id__pc
, output     [31:0] if_id__ins
, output reg        pipe_flush = 1
);
   reg  [31:0] pc = 0;
   wire [31:0] pc4 = pc + 4;
   wire [31:0] imem_addr = pc;
   wire [31:0] imem_data;
   wire [31:0] next_pc;
   wire        jump_taken = pipe_flush ? 1'b0 : mb_if__jump_taken;

   /* FIXME: misaligned */

   wire        no_hazard = !data_hazard;

   imem if_imem ( .clk(clk)
                , .addr(imem_addr[9:2])
                , .read(no_hazard)
                // output
                , .data(imem_data)
                );

   assign if_id__ins = imem_data;

   assign next_pc = jump_taken ? mb_if__jump_target : pc4;

   always @(posedge clk) begin
      // outputs
      if (no_hazard) begin
         if_id__pc <= pc;
         pc <= next_pc;
      end

      pipe_flush <= jump_taken;
   end

endmodule
