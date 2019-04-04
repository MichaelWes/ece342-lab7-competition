module RF
(
   clk, 
   reset,
   reg1,
   reg2,
   regw,
   dataw,
   data2,
   data1,
   RFWrite,
	regs
);
   input clk;
   input reset;
   
   output logic [7:0][15:0] regs;

   input [2:0] reg1; //src1
   input [2:0] reg2; //src2
   input [2:0] regw; // dst
   input RFWrite;

   input [15:0] dataw;
   output [15:0] data1;
   output [15:0] data2;

   assign data1 = regs[reg1];
   assign data2 = regs[reg2];
   
   always_ff @(posedge clk) begin
      if(reset) begin
         regs <= {16'hBADD, 16'hCAFE, 16'hBADD, 16'hCAFE, 16'hBADD, 16'hCAFE, 16'hBADD, 16'hCAFE};
      end else begin
         if(RFWrite) begin
            regs[regw] <= dataw;
         end
      end
   end

endmodule