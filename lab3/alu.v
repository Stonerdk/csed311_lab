`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, func_code, alu_output);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	input [2:0] func_code;
	output reg [`NumBits-1:0] alu_output;

	always @(func_code or alu_input_1 or alu_input_2) begin
		case (func_code)
		`FUNC_ADD: begin
			alu_output = alu_input_1 + alu_input_2;
		end
		`FUNC_SUB: begin
			alu_output = alu_input_1 - alu_input_2; // change order?
		end
		`FUNC_AND: begin
			alu_output = alu_input_1 & alu_input_2;
		end
		`FUNC_ORR: begin
			alu_output = alu_input_1 | alu_input_2;
		end
		`FUNC_NOT: begin
			alu_output = ~alu_input_1;
		end
		`FUNC_TCP: begin
			alu_output = ~alu_input_1 + 1;
		end
		`FUNC_SHL: begin
			alu_output = alu_input_1 << 1;
		end
		`FUNC_SHR: begin
			alu_output = alu_input_1 >> 1; // todo : sign extension
		end
		default: begin
			alu_output = alu_input_1;
		end
	end
endmodule