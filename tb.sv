module tb();

localparam string PROGRAMS[] = 
{
	"0_basic.hex",
	"1_arithdep.hex",
	"2_branch_nottaken.hex",
	"3_branch_taken.hex",
	"4_memdep.hex",
	"5_capital.hex"
};

// Create a 100MHz clock
logic clk;
initial clk = '0;
always #5 clk = ~clk;

// Create the reset signal 
logic reset;

// HASH TABLES WITH ENCODED INSTRUCTIONS
string instr_list_0 [integer] = '{
// Prog 0
16'h0710: "mvi r0, 7",
16'h0630: "mvi r1, 6",
16'h0550: "mvi r2, 5",
16'h0470: "mvi r3, 4",
16'h0390: "mvi r4, 3",
16'h02b0: "mvi r5, 2",
16'h01d0: "mvi r6, 1",
16'h00f0: "mvi r7, 0",
16'h0112: "subi r0, 1",
16'h0132: "subi r1, 1",
16'h0152: "subi r2, 1",
16'h0172: "subi r3, 1",
16'h0192: "subi r4, 1",
16'h01b2: "subi r5, 1",
16'h01d2: "subi r6, 1",
16'h01f2: "subi r7, 1",
16'h0011: "addi r0, 0",
// Prog 1
16'h0130: "mvi r1, 1",
16'h0250: "mvi r2, 2",
16'h0370: "mvi r3, 3",
16'h0590: "mvi r4, 5",
16'h0141: "add r2, r1",
16'h0261: "add r3, r2",
16'h0281: "add r4, r2",
16'h0121: "add r1, r1",
16'h04e0: "mv r7, r4",
16'h01e1: "add r7, r1",
16'h03e1: "add r7, r3",
16'h0090: "mvi r4, 0",
16'h0330: "mvi r1, 3",
16'h0250: "mvi r2, 2",
16'h0170: "mvi r3, 1",
16'h0380: "mv r4, r3",
16'h0160: "mv r3, r1",
16'h0420: "mv r1, r4",
16'h0232: "subi r1, 2",
16'h01c0: "mv r6, r1",
16'hfe10: "mvi r0, 0xFE",
16'hff16: "mvhi r0, 0xFF",
16'h0111: "addi r0, 1",
16'h00a0: "mv r5, r0",
16'h0011: "addi r0, 0",
// Prog 2
16'h00d0: "mvi r6, 0",
16'h00f0: "mvi r7, 0",
16'h0010: "mvi r0, 0",
16'h0011: "addi r0, 0",
16'h01d1: "addi r6, 1",
16'h0111: "addi r0, 1",
16'h01d9: "jz error",
16'h0010: "mvi r0, 0",
16'h0112: "subi r0, 1",
16'h015a: "jn error",
16'h2a30: "mvi r1, error",
16'h0010: "mvi r0, 0",
16'h0011: "addi r0, 0",
16'h0111: "addi r0, 1",
16'h0029: "jzr r1",
16'h0010: "mvi r0, 0",
16'h0112: "subi r0, 1",
16'h0111: "addi r0, 1",
16'h002a: "jnr r1",
16'hfff8: "j measure_end",
16'h01f0: "mvi r7, 1",
16'hffb8: "j measure_end",
16'h0000: "mv r0, r0", // 001a: .dw 0
// Prog 3
16'h00b0: "mvi r5, 0",
16'h00d0: "mvi r6, 0",
16'h00bc: "call testfunc",
16'h01b1: "addi r5, 1",
16'h01d1: "addi r6, 1",
16'h00d8: "j .0f",
16'h01b1: "addi r5, 1",
16'h01d1: "addi r6, 1",
16'h04f1: "addi r7, 4",
16'h00e8: "jr r7",
16'h10f0: "mvi r7, testfunc",
16'h00ec: "callr r7",
16'h0058: "j .0f",
16'h01b1: "addi r5, 1",
16'h0110: "mvi r0, 1",
16'h0011: "addi r0, 0",
16'h0112: "subi r0, 1",
16'h34f0: "mvi r7, .0f",
16'h00e9: "jzr r7",
16'h0010: "mvi r0, 0",
16'h42f0: "mvi r7, .0f",
16'h00ea: "jnr r7",
16'h0110: "mvi r0, 1",
16'h0059: "jz .0f",
16'h0010: "mvi r0, 0",
16'h005a: "jn measure_end",
16'hfff8: "j measure_end",
// Prog4
16'h0010: "mvi r0, 0",
16'h1610: "mvi r0, memvar1",
16'h0004: "ld r0, r0",
16'h0024: "ld r1, r0",
16'h0531: "addi r1, 5",
16'h0211: "addi r0, 2",
16'h0025: "st r1, r0",
16'h1810: "mvi r0, memvar2",
16'h0211: "addi r0, 2",
16'h00e4: "ld r7, r0",
16'hfff8: "j measure_end",
16'h0018: ".dw memvar2",
16'h0005: ".dw 5",
// Prog5
16'h2c10: "mvi r0, str",
16'h0024: "ld r1, r0",	
16'h0033: "cmpi r1, 0",
16'h00b9: "jz done",
16'h0180: "mv r4, r1",	
16'h011c: "call toupper",
16'h0025: "st r1, r0",	
16'h0211: "addi r0, 2",
16'hff18: "j loop_top",
16'h2c30: "mvi r1, str",
16'h0210: "mvi r0, 0x02",
16'h1016: "mvhi r0, 0x10",
16'h0025: "st r1, r0",
16'hfff8: "end: j end",
16'h0420: "mv r1, r4",		
16'h6133: "cmpi r1, 'a'",	
16'h00ea: "jnr r7",
16'h7b33: "cmpi r1, '{'",
16'h003a: "jn .0f",
16'h00e8: "jr r7",
16'h2032: "subi r1, 0x20",
16'h00e8a: "jr r7",
default: ""
};

string __instr;
string Fetch, Decode, Execute_Memory, Writeback;

// Declare the bus signals, using the CPU's names for them
logic [15:0] o_pc_addr;
logic o_pc_rd;
logic [15:0] i_pc_rddata;
logic [15:0] o_ldst_addr;
logic o_ldst_rd;
logic o_ldst_wr;
logic [15:0] i_ldst_rddata;
logic [15:0] o_ldst_wrdata;
logic [7:0][15:0] o_tb_regs;

// Instantiate the processor and hook up signals.
// Since the cpu's ports have the same names as the signals
// in the testbench, we can use the .* shorthand to automatically match them up
cpu dut(.*);

// Create a 16KB memory, dual-ported
logic [15:0] mem [0:8191];

always_comb begin
    __instr = instr_list_0[i_pc_rddata[15:0]];
    Fetch = (tb.dut.f0.f_valid) ? instr_list_0[mem[o_pc_addr[15:1]]] : "";
    Decode = (tb.dut.r0.d_valid) ? __instr : "";
    Execute_Memory = (tb.dut.ex0.ex_valid) ? instr_list_0[tb.dut.ID_EX[15:0]] : "";
    Writeback = (tb.dut.wb0.wb_valid) ? instr_list_0[tb.dut.EX_WB[15:0]] : "";
end

// Define memory functionality.
always_ff @ (posedge clk) begin
	//
	// PORT 1 (pc read)
	//

	// Read logic.
	// For extra compliance, fill readdata with garbage unless
	// rd enable is actually used.
	if (o_pc_rd) begin
		i_pc_rddata <= mem[o_pc_addr[15:1]];
	end
	else begin 
		i_pc_rddata <= 16'bx;
	end
	
	//
	// PORT 2 (loads and stores)
	//
	
	// Read logic.
	if (o_ldst_rd) begin
		i_ldst_rddata <= mem[o_ldst_addr[15:1]];
	end
	else begin 
		i_ldst_rddata <= 16'bx;
	end
	
	// Write logic
	if (o_ldst_wr) begin
		case (o_ldst_addr)
		16'h1000: begin
			// Writing a number to 0x1000 will display it
			$display("Integer result: %h", o_ldst_wrdata);
		end
		
		16'h1002: begin
			// Writing an address to 0x1002 will print the null-terminated string
			// at that address, as long as it's up to 512 characters long.
			int rd_addr;
			string str;
			int str_len;
			
			// Allocate a verilog string with 512 characters (we can't expand strings apparently).
			// rd_addr points to the string to print out, and the CPU gave this to us
			str = {512{" "}};
			str_len = 0;
			rd_addr = o_ldst_wrdata;

			while (str_len < 512) begin
				logic [15:0] rd_val;
				rd_val = mem[rd_addr >> 1];
				
				if (rd_val == 16'hxxxx) begin
					$display("Bad string result: got xxxx at address %h",
						rd_addr);
				end
				
				// The lower 8 bits of the 16-bit word are an ASCII character to add to the string
				str.putc(str_len, rd_val[7:0]);
				
				// Got null terminator, we're done
				if (rd_val == 16'd0) 
					break;
				
				// Advance memory read position (by 1 word) and string write position
				rd_addr += 2;
				str_len++;
			end
			
			// Ran out of string room?
			if (str_len == 512) begin
				$display("Bad string result: no null terminator found after 512 chars");
				$stop();
			end
		
			// Got string, display it
			$display("String result: %s", str.substr(0, str_len-1));
		end
		
		// All other addresses: just write to memory
		default: begin
			mem[o_ldst_addr[15:1]] <= o_ldst_wrdata;
		end
		endcase
	end
end

// Test State
struct
{
	// Starting and ending PCs (inclusive) of IPC measurement region
	bit [15:0] measure_start;
	bit [15:0] measure_end;
	// Number of instructions in test (manually entered)
	integer n_instrs;
	// Minimum expected IPC
	real min_ipc;
	// Bitmask of which registers need validation
	bit [7:0] check_regs;
	// The expected valid values of said registers
	bit [15:0] reg_vals[8];
	
	// Cycle counters for measurement
	bit measure_enable;
	integer measure_cycles;
	//integer measure_instrs; // used for verification
} tstate;

// Snoop on the CPU's instruction fetching.
always_ff @ (posedge clk) begin
	// Once it fetches the instruction at the measure_start address,
	// then this testbench is now in measuring mode.
	if (o_pc_rd && o_pc_addr == tstate.measure_start) begin
		tstate.measure_enable = '1;
	end
	
	// Count every cycle in which we're in measuring mode.
	if (tstate.measure_enable) begin
		tstate.measure_cycles++;
		
		//if (o_pc_rd) tstate.measure_instrs++;
		//if (dut.ctrl.br_taken_3 && dut.dp.valid_3) tstate.measure_instrs -= 2;
	end
	
	// Once the CPU fetches the instruction at PC=measure_end,
	// that's the last instruction in the measurement region.
	// Turn off measuring mode now.
	if (o_pc_rd && o_pc_addr == tstate.measure_end) begin
		tstate.measure_enable = '0;
	end
end

task reset_cpu();
	reset = '1;
	@(posedge clk);
	@(posedge clk);
	reset = '0;
endtask

// Load the test metadata section from byte address 0x1000
task load_metadata();
	tstate.measure_start = mem[16'h800];
	tstate.measure_end = mem[16'h801];
	tstate.n_instrs = mem[16'h802];
	tstate.min_ipc = real'(mem[16'h803]) / 128.0;
	tstate.check_regs = mem[16'h804][7:0];
	for (integer i = 0; i < 8; i++) begin
		tstate.reg_vals[i] = mem[16'h805 + i];
	end
endtask

// Validate correctness of benchmark
task check_regs();
	bit all_passed;
	string detailed_info;
	all_passed = '1;
	
	// Benchmark has no correctness conditions? Exit quietly
	if (tstate.check_regs == '0)
		return;
	
	// First, check the registers
	detailed_info = "REG\tEXPECTD\tACTUAL\tRESULT\n";
	for (integer i = 0; i < 8; i++) begin
		logic [15:0] expected;
		logic [15:0] actual;
		bit pass;
		string detailed_line;
		
		// Does the benchmark care about this register?
		if (!tstate.check_regs[i]) continue;
		
		expected = tstate.reg_vals[i];
		actual = o_tb_regs[i];
		pass = expected == actual;
		
		detailed_line = $sformatf("R%0d\t0x%4x\t0x%4x\t%s\n",
			i,
			expected,
			actual,
			pass? "Pass" : "FAIL"
		);
		
		detailed_info = {detailed_info, detailed_line};
		all_passed &= pass;
	end
	
	$display("Functional correctness: %s",
		all_passed? "Pass" : "FAIL");
	
	if (!all_passed)
		$display(detailed_info);
endtask

// Validate performance of benchmark
task check_ipc();
	real ipc;
	
	ipc = tstate.measure_cycles > 0 ?
		real'(tstate.n_instrs) / real'(tstate.measure_cycles) : 0;
	
	$display("Instructions/cycles: %0d/%0d",
		tstate.n_instrs,
		tstate.measure_cycles
	);
	
	$display("IPC expected/achieved: %02f/%02f",
		tstate.min_ipc, ipc);
		
	$display("Performance result: %s",
		ipc >= tstate.min_ipc ? "Pass" : "FAIL");
endtask

task do_test(integer test_no);
	string hex_file;
	integer fp;

	// Reset the CPU
	reset_cpu();
	
	// Load the program
	hex_file = PROGRAMS[test_no];
	$display("================================");
	$display("Starting test %0d (%s)", test_no, hex_file);
	// Extra check to see if file exists
	fp = $fopen(hex_file, "r");
	if (fp == 0) begin
		$error("Couldn't open %s", hex_file);
		$stop;
	end
	$fclose(fp);
	$readmemh(hex_file, mem);
	
	// Parse metadata section
	load_metadata();
	
	// Init test counters
	tstate.measure_enable = 0;
	tstate.measure_cycles = 0;
	//tstate.measure_instrs = 0;
	
	// Wait for the program to do its thing and for
	// measurement to be done
	wait(tstate.measure_enable == 1);
	$display("Entered test region PC=%0x", tstate.measure_start);
	wait(tstate.measure_enable == 0);
	$display("Exited test region PC=%0x", tstate.measure_end);
	
	// Let the pipeline settle
	@(posedge clk);	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	// Check results
	check_regs();	
	check_ipc();
	//$display("Measured instrs: %0d", tstate.measure_instrs);
	$display("================================");
endtask

initial begin
	// Comment these out to run only certain tests.
	//do_test(0);
	//do_test(1);
	//do_test(2);
	//do_test(3);
	//do_test(4);
	do_test(5);
	
	$stop;
end

endmodule
