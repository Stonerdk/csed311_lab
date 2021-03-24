`include "opcodes.v"
`define	NumBits	16

module alu (alu_input_reg, alu_input_imm, opcode, alu_output);
	input [`NumBits-1:0] alu_input_reg;
	input [`NumBits-1:0] alu_input_imm;
	input [4:0] opcode;
	output reg [`NumBits-1:0] alu_output;

	always @(opcode or alu_input_1 or alu_input_2) begin
		case (func_code)
		`ADI_OP: begin
            alu_output = alu_input_reg + alu_input_imm;
        end
        `ORI_OP: begin
            alu_output = alu_input_reg | alu_input_imm; 
        end
        `LHI_OP: begin
            alu_output = alu_input_reg << 8;
        end
		default: begin
			alu_output = alu_input_1;
		end
	end
endmodule