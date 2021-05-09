`include "opcodes.v" 

module branch_predictor(clk, reset_n, PC, instruction, ifid_branch, bcond, next_PC, eval_bcond);

	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] PC;
	input [`WORD_SIZE-1:0] instruction;
	input ifid_branch;
	input bcond; // not taken

	output [`WORD_SIZE-1:0] next_PC;
	output eval_bcond;

	reg[1:0] saturation;
	wire [`WORD_SIZE-1:0] imm;

	// assign next_PC = PC + 1;

	assign imm[7:0] = instruction[7:0];
	assign imm[15:8] = imm[7] ? 8'hff : 8'h00;
	assign eval_bcond = saturation[1];
	assign next_PC = saturation[1] ? PC + imm + 1 : PC + 1;

	always @(posedge clk) begin
		if (!reset_n) begin
			saturation <= 2'b01;
		end	

		if (ifid_branch) begin
			if (bcond)
				saturation <= saturation != 2'b00 ? saturation - 1 : 0;
			else
				saturation <= saturation != 2'b11 ? saturation + 1 : 0;
		end
	end 
endmodule
