`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, func_code, alu_output);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	input [2:0] func_code;
	output reg [`NumBits-1:0] alu_output;

	always @(*) begin
		case (func_code)
			'NumBits'd0 alu_output = alu_input_1 + alu_input2;
			'NumBits'd1 alu_output = alu_input_1 + alu_input2;
			'NumBits'd2 alu_output = alu_input_1 + alu_input2;
			'NumBits'd3 alu_output = alu_input_1 + alu_input2;
			'NumBits'd4 alu_output = alu_input_1 + alu_input2;
			'NumBits'd5 alu_output = alu_input_1 + alu_input2;
			'NumBits'd6 alu_output = alu_input_1 + alu_input2;
			'NumBits'd7 alu_output = alu_input_1 + alu_input2;
			'NumBits'd27 alu_output = alu_input_1 + alu_input2;
			'NumBits'd28 alu_output = alu_input_1 + alu_input2;
			'NumBits'd29 alu_output = alu_input_1 + alu_input2;
			'NumBits'd30 alu_output = alu_input_1 + alu_input2;
			'NumBits'd31 alu_output = alu_input_1 + alu_input2;
			'NumBits'd32 alu_output = alu_input_1 + alu_input2;
			'NumBits'd33 alu_output = alu_input_1 + alu_input2;
			'NumBits'd34 alu_output = alu_input_1 + alu_input2;
		endcase

	end

endmodule