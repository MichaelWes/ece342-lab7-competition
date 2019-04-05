import definesPkg::*;

module datapath_execute
(
   clk,
   reset,
   ID_EX,
   EX_WB,
	ALUop,
	ALUop1,
	ALUop2,
	ALUout,
	Z,
	N,
	update_flags,
   o_ldst_addr,
   o_ldst_rd,
   o_ldst_wr,
   o_ldst_wrdata,
	dataw,
	regw,
	BT,
	taken,
	d_valid,
	ex_valid,
	i_wr,
	i_valid,
	already_valid,
	w_PC,
	BTBtable
);
   input clk;
   input reset;   
   input d_valid;
	input already_valid; // hack for fixing speculation
	output logic i_wr;
	output logic i_valid;
	output logic [15:0] w_PC;
	
	// branch instruction logic
	output logic [15:0] BT;
	output logic taken;
	
	// speculation 
	input [BTB_num_rows - 1:0][17:0] BTBtable;
	
   input [ID_EX_WIDTH-1:0] ID_EX;
   output logic [EX_WB_WIDTH-1:0] EX_WB;
		
	// Reassign names to ID_EX sub ranges within this module
   wire [15:0] PC;
   wire [15:0] instr;
   wire [15:0] data1; //[Rx]
   wire [15:0] data2; //[Ry]
   wire [15:0] s_ext_imm8;
   wire [15:0] s_ext_imm11;
	
	output logic ex_valid;
	
	wire [2:0] Rx;
	wire [2:0] Ry;
	wire Rx_valid, Ry_valid;
	wire [15:0] instr_PC;
	
   assign {instr_PC, Rx_valid, Ry_valid, Rx, Ry, s_ext_imm8, s_ext_imm11, data1, data2, PC, instr} = ID_EX;
	
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			ex_valid <= '0;
		end else begin
			ex_valid = (taken) ? '0 : d_valid;
		end
	end
	
   // ALU
   output logic [2:0] ALUop;	
   output logic [15:0] ALUop1;
   output logic [15:0] ALUop2;
	input [15:0] ALUout;
	input Z, N;
	output logic update_flags;
	
	// ld/st signals 
	output logic [15:0] o_ldst_addr;
   output logic o_ldst_rd;
   output logic o_ldst_wr;
   output logic [15:0] o_ldst_wrdata;
	
	wire [4:0] opcode = instr[4:0];
	
	// forwarded signals from WB stage
	input [15:0] dataw;
	input [2:0] regw;
	
	// forwarded operands, or operands read from ID_EX, whichever is more recent
	logic [15:0] operand1;
	logic [15:0] operand2;
	
	// Operand forwarding logic
	always_comb begin
		operand1 = data1;
		operand2 = data2;
		if((regw == Rx) & Rx_valid) begin
			operand1 = dataw;
		end
		if((regw == Ry) & Ry_valid) begin
			operand2 = dataw;
		end
	end
	
	always_comb begin
		taken = '0;
		if(ex_valid) begin
			casex(opcode)
				// jr, callr, instructions imply the branch should be taken. Not speculating for these (yet).
				5'b01x00: begin 
					taken = '1; 
				end
				// j, call
				5'b11x00: begin
					taken = ~BTBtable[instr_PC[4:0]][17]; // because we don't want to take it twice... look at the BTB valid bit to determine whether to take the branch. 
				end
				// jz, jzr instructions imply branch is taken when the condition holds
				5'bx1001: begin
					taken = Z;
				end
				// jn, jnr instructions imply branch is taken when the condition holds
				5'bx1010: begin
					taken = N;
				end
				default: begin
					taken = '0;
				end
			endcase
		end
	end
	
	always_comb begin
		BT = ALUout;
		i_wr = '0;
		i_valid = '0;
		w_PC = 'x;
		if(ex_valid & taken) begin
			casex(opcode) 
				// call, j | Don't bother with  jz + jzr | jn + jnr.
				5'b11x00: begin
					i_wr = '1;
					i_valid = '1;
					w_PC = instr_PC;
				end
			endcase
		end
	end
	
	always_comb begin
		update_flags = '0;
		casex(opcode)
			// mv
			5'b00000: begin
				ALUop1 = '0;
				ALUop2 = operand2;
			end
			// add
			5'b00001: begin
				ALUop1 = operand1;
				ALUop2 = operand2;
				update_flags = '1;
			end
			// sub, cmp
			5'b0001x: begin
				ALUop1 = operand1;
				ALUop2 = operand2;
				update_flags = '1;
			end
			// mvi
			5'b10000: begin
				ALUop1 = '0;
				ALUop2 = s_ext_imm8;
			end
			// addi
			5'b10001: begin
				ALUop1 = operand1;
				ALUop2 = s_ext_imm8;
				update_flags = '1;
			end
			// subi, cmpi
			5'b1001x: begin
				ALUop1 = operand1;
				ALUop2 = s_ext_imm8;
				update_flags = '1;
			end
			// mvhi
			5'b10110: begin
				ALUop1 = operand1;
				ALUop2 = instr[15:8]; // imm8
			end
			// call, j, jz, jn
			5'b11100, 5'b11000, 5'b11001, 5'b11010: begin
				ALUop1 = PC;
				ALUop2 = s_ext_imm11;
			end
			// callr, jr, jzr, jnr
			5'b01100, 5'b01000, 5'b01001, 5'b01010: begin
				ALUop1 = operand1;
				ALUop2 = 'x;
			end
			// TODO: ALU operands MUX for the rest of the instructions
			default: begin
				ALUop1 = 'x;
				ALUop2 = 'x;
			end
		endcase
	end

   always_comb begin
      // ALUop signal generated based on the instruction
      casex(opcode) 
         // mv, add, mvi, addi
         5'bx000x: ALUop = 3'b000; 
         // sub, cmp, subi, cmpi
         5'bx001x: ALUop = 3'b001;
			// mvhi
			5'b10110: ALUop = 3'b100;
			// j, jz, jn, call
			5'b1100x, 5'b11010, 5'b11100: ALUop = 3'b010;
			// for jr, jzr, jnr, callr
			5'b0100x, 5'b01010, 5'b01100: ALUop = 3'b011;
         default: ALUop = '0;
      endcase
   end
	
	// Generate signals for loads and stores
	always_comb begin
		if(ex_valid) begin
			case(opcode)
				// ld
				5'b00100: begin
					o_ldst_addr = operand2;
					o_ldst_rd = 1'b1;
					o_ldst_wr = 1'b0;
					o_ldst_wrdata = 'x;
				end
				// st
				5'b00101: begin
					o_ldst_addr = operand2;
					o_ldst_rd = 1'b0;
					o_ldst_wr = 1'b1;
					o_ldst_wrdata = operand1;
				end
				default: begin
					o_ldst_addr = 'x;
					o_ldst_wrdata = 'x;
					o_ldst_wr = '0;
					o_ldst_rd = '0;
				end
			endcase
		end else begin
			o_ldst_addr = 'x;
			o_ldst_wrdata = 'x;
			o_ldst_wr = '0;
			o_ldst_rd = '0;
		end
	end
   
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			EX_WB <= '0;
		end else begin
			EX_WB <= {instr_PC + 16'd2, data1, data2, ALUout, instr};
		end
	end
	
endmodule