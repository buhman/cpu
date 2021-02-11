module cpu_op_tb;

   reg clk = 0;
   always #2 clk = !clk;

   wire [31:0] imem_addr;
   reg [31:0] imem_data;

   cpu c (.clk(clk),
          .imem_addr(imem_addr),
          .imem_data(imem_data)
          );

   initial begin
      #0 begin
         imem_data = 31'h01700193; // addi	x3,x0,23
      end

      #4 begin
         imem_data = 31'h01300113; // addi	x2,x0,19
      end

      #4 begin
         imem_data = 31'h003100b3; // add	x1,x2,x3
      end

      #8 $finish;
   end

   initial
     $monitor("%t %d %h %h", $time, clk, imem_addr, imem_data);

endmodule
