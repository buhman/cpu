`include "include.v"

module imm_tb;

   reg [2:0] imm_type;
   reg [31:0] ins;
   wire [31:0] imm;
   wire [31:7] ins_i;

   assign ins_i = ins[31:7];

   imm_gen ig (.imm_type(imm_type),
               .ins_i(ins_i),
               .imm(imm)
               );

   initial begin
      #1 $display("I-type");
      #1 begin
         imm_type = `IMM_I_TYPE;
         ins = 32'h00500713;
         // 5
      end
      #1 begin
         imm_type = `IMM_I_TYPE;
         ins = 32'h7ff00713;
         // 2047
      end
      #1 begin
         imm_type = `IMM_I_TYPE;
         ins = 32'hfff70713;
         // 4294967295 == "4095"
      end
      #1 begin
         imm_type = `IMM_I_TYPE;
         ins = 32'hfec42703;
         // 4294967276 == -20
      end
      #1 $display("S-type");
      #1 begin
         imm_type = `IMM_S_TYPE;
         ins = 32'h00812e23;
         // 28
      end
      #1 begin
         imm_type = `IMM_S_TYPE;
         ins = 32'hfe042623;
         // 4294967276 == -20
      end
      #1 $display("B-type");
      #1 begin
         imm_type = `IMM_B_TYPE;
         ins = 32'hfee79ee3;
         // 4294967292 == -4
      end
      #1 $display("U-type");
      #1 begin
         imm_type = `IMM_U_TYPE;
         ins = 32'h00001737;
         // 4096
      end
      #1 $display("J-type");
      #1 begin
         imm_type = `IMM_J_TYPE;
         ins = 32'hff5ff06f;
         // 4294967284 == -12
      end
      #1 $finish;
   end

   initial
     $monitor("%t   %h %b\n%t %d %b", $time, ins, ins, $time, imm, imm);
endmodule
