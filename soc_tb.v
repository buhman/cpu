module soc_tb;

   reg clk = 0;
   always #2 clk = !clk;

   wire   spi_sck;
   wire   pc_cs;
   wire   pc_mosi;
   soc s (.clk(clk),
          .spi_sck(spi_sck),
          .pc_cs(pc_cs),
          .pc_mosi(pc_mosi)
          );


   wire [31:0] a = 1836311903;
   wire [31:0] b = 2971215073;
   initial begin
      /*#1 $display("%h", a + b);
       #1 $finish;*/
      #150000 $finish;
   end

endmodule

/*
 00000000 <_start>:
   0:	00100693          	addi	x13,x0,1
   4:	00000713          	addi	x14,x0,0
   8:	00000613          	addi	x12,x0,0
   c:	00d707b3          	add	x15,x14,x13
  10:	00e7ec63          	bltu	x15,x14,28 <_start+0x28>
  14:	00061e63          	bne	x12,x0,30 <_start+0x30>
  18:	00f02023          	sw	x15,0(x0) # 0 <_start>
  1c:	00068713          	addi	x14,x13,0
  20:	00078693          	addi	x13,x15,0
  24:	fe5ff06f          	jal	x0,8 <_start+0x8>
  28:	00100613          	addi	x12,x0,1
  2c:	fe9ff06f          	jal	x0,14 <_start+0x14>
  30:	0000006f          	jal	x0,30 <_start+0x30>
*/
// 43a53f82
// 6d73e55f
// b11924e1
