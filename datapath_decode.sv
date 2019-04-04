import definesPkg::*;

module datapath_RF_Read
(
   clk,
   reset,
	i_pc_rddata,
   Rx,
   Ry,
   data1,
   data2,
   IF_ID,
   ID_EX,
	dataw,
	regw,
	taken,
	f_valid,
	d_valid
);
	input clk;
	input reset;
	input taken;
	input f_valid;
	output d_valid;
	
	input [15:0] i_pc_rddata;
	
	input          [IF_ID_WIDTH-1:0] IF_ID;
	output logic   [ID_EX_WIDTH-1:0] ID_EX;   
	
	wire [15:0] PC = IF_ID[31:16];
	wire [15:0] instr = i_pc_rddata[15:0];
	
	output logic [2:0] Rx;
	output logic [2:0] Ry;
	
	// signals indicating whether this instruction encodes register operand(s)
	logic Rx_valid, Ry_valid;
	
	input [15:0] data1; //[Rx]
	input [15:0] data2; //[Ry]
	
	logic [15:0] s_ext_imm8;
	logic [15:0] s_ext_imm11;

	logic d_valid;
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			d_valid <= '0;
		end else begin
			d_valid = (taken) ? '0 : f_valid;
		end
	end
	
	wire [4:0] opcode = instr[4:0];
	
	// forwarded signals from WB stage
	input [15:0] dataw;
	input [2:0] regw;
	
	// forwarded operands, or operands read from RF, whichever is more recent
	logic [15:0] operand1;
	logic [15:0] operand2;
	
   always_comb begin
      Ry = instr[10:8];		
      Rx = instr[7:5];
		casex(opcode) 
			5'bx00xx, 5'b0010x, 5'b10110, 5'b0100x, 5'b01010, 5'b01100: Rx_valid = '1;
			default: Rx_valid = '0;
		endcase
		casex(opcode) 
			5'b000xx, 5'b0010x: Ry_valid = '1;
			default: Ry_valid = '0;
		endcase
   end
	
	// Operand forwarding logic
	always_comb begin
		operand1 = data1;
		operand2 = data2;
		if(regw == Rx) begin
			operand1 = dataw;
		end
		if(regw == Ry) begin
			operand2 = dataw;
		end
	end
	
   always_comb begin
      // For mvi, addi, subi, cmpi
      s_ext_imm8 = {{8{instr[15]}}, instr[15:8]};
   end
   
   always_comb begin
      // For j, jz, jn, call
      s_ext_imm11 = {{5{instr[15]}}, instr[15:5]};
   end
   
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         ID_EX <= '0;   
      end else begin
         // TODO: Other information to pass along?
         ID_EX <= {Rx_valid, Ry_valid, Rx, Ry, s_ext_imm8, s_ext_imm11, operand1, operand2, PC, instr};  
      end
   end
endmodule
