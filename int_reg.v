/*
 ice40: 69 LUT , 71 LC     , 8.96ns
 ecp5:  73 LUT , 165 SLICE , 11.56ns
 */
module int_reg
( input         clk
, input 	rd_wen
, input  [4:0]  rd_addr
, input  [4:0]  rs1_addr
, input  [4:0]  rs2_addr
, input  [31:0] rd_wdata
, output reg [31:0] rs1_rdata
, output reg [31:0] rs2_rdata
);

   reg [31:0] regs [1:31];

   always @(negedge clk) begin
      if (rd_wen && (rd_addr != 0)) begin
         regs[rd_addr] <= rd_wdata;
      end

      if (rd_wen)
        $display("%t rd_wen rd=%d rd_wdata=%h %d", $time, rd_addr, rd_wdata, rd_wdata);
   end

   always @(posedge clk) begin
      /* encourage yosys to infer memory */
      if (rs1_addr == 0)
        rs1_rdata <= 32'd0;
      else
        rs1_rdata <= regs[rs1_addr];

      if (rs1_addr == 0)
        rs2_rdata <= 32'd0;
      else
        rs2_rdata <= regs[rs2_addr];
   end
endmodule
