module int_regs
  (
   input         clk, wen,
   input [4:0]   rd_addr,
   input [4:0]   rs1_addr,
   input [4:0]   rs2_addr,
   input [31:0]  rd_wdata,
   output [31:0] rs1_rdata,
   output [31:0] rs2_rdata
   );

   reg [31:0]    regs [0:30];

   always @(posedge clk) begin
      if (wen && (rd_addr != 0)) begin
         regs[rd_addr - 1] <= rd_wdata;
      end
   end

   /*
   always @(negedge clk) begin
    rs1_rdata <= rs1_addr ? regs[rs1_addr - 1] : 0;
    rs2_rdata <= rs2_addr ? regs[rs2_addr - 1] : 0;
   end
    */

   assign rs1_rdata = rs1_addr ? regs[rs1_addr - 1] : 0;
   assign rs2_rdata = rs2_addr ? regs[rs2_addr - 1] : 0;
endmodule
