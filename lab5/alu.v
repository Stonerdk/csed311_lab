`include "opcodes.v" 

module branch_alu (A, B, opcode, bcond);
	input [`WORD_SIZE-1:0] A, B;
	input [3:0] opcode;
	output reg bcond;
	always @(*) begin
		case (opcode)
			0: bcond = A != B;
			1: bcond = A == B;
			2: bcond = (A[15] == 0) && (A != 0);
			3: bcond = A[15] == 1;
			default: bcond = 0;
		endcase
	end
endmodule		

module alu (A, B, func_code, alu_out);
	input [`WORD_SIZE-1:0] A;
	input [`WORD_SIZE-1:0] B;
	input [3:0] func_code;

	output reg [`WORD_SIZE-1:0] alu_out;

	always @(*) begin
		case (func_code)
			0 : alu_out = A + B;
			1 : alu_out = A - B;
			2 : alu_out = A & B;
			3 : alu_out = A | B;
			4 : alu_out = ~A;
			5 : alu_out = -A;
			6 : alu_out = A << 1;
			7 : alu_out = A >> 1;
			8 : alu_out = B << 8;
			9 : alu_out = A;
			default: alu_out = A + B;
		endcase
	end
endmodule