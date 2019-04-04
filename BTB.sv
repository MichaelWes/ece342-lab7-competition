import definesPkg::*;

module BTB
(
	clk,
	reset,
	i_wr,
	w_PC,
	r_PC,
	i_valid, // tells us whether to WRITE the valid bit of _BTB[i_PC & 0x00FF]
	i_BT,
	o_valid,
	o_BT
);
	input clk;
	input reset;
	input i_wr, i_valid;
	input [15:0] i_BT;
	input [15:0] r_PC;
	input [15:0] w_PC;
	
	wire [7:0] rindex = (r_PC & 16'h00FF);
	wire [7:0] windex = (w_PC & 16'h00FF);
	
	output logic o_valid;
	output logic [15:0] o_BT;
	
	// This is 17 bits because the MSB is a valid bit
	logic [BTB_num_rows - 1:0][16:0] BTBtable;
	
	always_comb begin
		o_BT = BTBtable[rindex][15:0];
		o_valid = BTBtable[rindex][16];
	end
	
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			BTBtable <= '0;
		end else begin
			// Asserted in Execute stage, based on opcode.
			if(i_wr) begin
				BTBtable[windex] <= {i_valid, i_BT};
			end
		end
	end

endmodule