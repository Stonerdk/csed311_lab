`include "opcodes.v" 

module branch_predictor(clk, reset_n, PC, is_flush, taken, datahazard, is_branch, is_jump, actual_next_PC, actual_PC, next_PC);

	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] PC;
	input is_flush;
	input taken;
	input datahazard;
	input is_branch, is_jump;
	input [`WORD_SIZE-1:0] actual_next_PC; //computed actual next PC from branch resolve stage
	input [`WORD_SIZE-1:0] actual_PC; // PC from branch resolve stage

	output [`WORD_SIZE-1:0] next_PC;

	wire [7:0] actual_pc_idx;
	wire [7:0] actual_pc_tag;
	wire [7:0] pc_idx;
	wire [7:0] pc_tag;
	wire cache_hit;

	reg [7:0] TAG [0:255];
	reg [`WORD_SIZE-1:0] TARGET [0:255];
	reg [1:0] SATURATION;
	reg [`WORD_SIZE-1:0] i;

	assign actual_pc_idx = actual_PC[7:0];
	assign actual_pc_tag = actual_PC[15:8];
	assign pc_idx = PC[7:0];
	assign pc_tag = PC[15:8];
	
	assign cache_hit = pc_tag == TAG[pc_idx];
	assign next_PC = is_flush ? actual_next_PC : ((cache_hit && (SATURATION[1] || is_jump)) ? TARGET[pc_idx] : PC + 1);
	//assign next_PC = is_flush ? actual_next_PC : cache_hit ? TARGET[pc_idx] : PC + 1; // always taken
	//assign next_PC = is_flush ? actual_next_PC : PC + 1; //always not taken
	always @(posedge clk) begin
		if (!reset_n) begin
			for (i = 1; i < 256; i = i + 1) begin
				TAG[i] <= 0;
				TARGET[i][15:8] <= 0;
				TARGET[i][7:0] <= i + 1;
			end
			TAG[0] <= 0;
			TARGET[0] <= 35;
			SATURATION <= 2;
		end

		else begin
			
			if ((is_branch || is_jump) && !datahazard) begin
				if (is_branch) begin
					if (taken)
						SATURATION <= SATURATION == 3 ? 3 : SATURATION + 1;
					else
						SATURATION <= SATURATION == 0 ? 0 : SATURATION - 1;
				end
				TAG[actual_pc_idx] <= actual_pc_tag;
				TARGET[actual_pc_idx] <= actual_next_PC;
			end	
		end
	end
endmodule
