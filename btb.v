module btb
(
  input clk

, input [31:0] update_pc
, input [31:0] update_target
, input        update_taken

, input [31:0] pc

, output [31:0] predict_target
, output        predict_taken
);
   localparam ENTRIES = 8;
   localparam INDEX_BITS = $clog2(ENTRIES);
   localparam OFFSET = 2;

   reg [64:0] entries [0:ENTRIES-1];

   genvar     i;
   generate
      for (i = 0; i < ENTRIES; i = i + 1)
        initial
          entries[i][32] = 1'b0;
   endgenerate

   // prediction

   wire [INDEX_BITS-1:0] predict_index;
   wire [31:0]           predict_pc;
   wire                  taken;

   assign predict_index = pc[INDEX_BITS+OFFSET-1:OFFSET];
   assign {taken, predict_target, predict_pc} = entries[predict_index];
   assign predict_taken = (predict_pc == pc && taken);

   // update

   wire [INDEX_BITS-1:0] update_index;

   assign update_index = update_pc[INDEX_BITS+OFFSET-1:OFFSET];

   always @(posedge clk) begin
      if (update_taken) begin
        entries[update_index] <= {update_taken, update_target, update_pc};
      end
   end

endmodule
