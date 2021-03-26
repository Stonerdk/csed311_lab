`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, alu_op, func_code, alu_output, condition_bit);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	
	input [4:0] alu_op; 
	input [2:0] func_code;

	output reg [`NumBits-1:0] alu_output;
	output reg condition_bit; 

	always @(*) begin
		if (alu_op == `ALU_OP) begin
			case(func_code)
			`FUNC_ADD: begin
			alu_output = alu_input_1 + alu_input_2;
			end
			`FUNC_SUB: alu_output = alu_input_1 - alu_input_2;		 
			`FUNC_AND: alu_output = alu_input_1 & alu_input_2;
			`FUNC_ORR: alu_output = alu_input_1 | alu_input_2;								     
				`FUNC_NOT: alu_output = ~alu_input_1;
			`FUNC_TCP: alu_output = ~alu_input_1 + 1;
			`FUNC_SHL: alu_output = alu_input_1 << 1;
			`FUNC_SHR: alu_output = alu_input_1 >> 1;	
			default: alu_output = alu_output;
			endcase
		end
		else begin
			case(alu_op)
			`ADI_OP: alu_output = alu_input_1 + alu_input_2;
			`ORI_OP: alu_output = alu_input_1 | alu_input_2;
			`LHI_OP: alu_output = alu_input_2 << 8;
			`LWD_OP: alu_output = alu_input_1 + alu_input_2; 		  
			`SWD_OP: alu_output = alu_input_1 + alu_input_2;
			`BNE_OP: condition_bit = (alu_input_1 != alu_input_2);
			`BEQ_OP: condition_bit = (alu_input_1 == alu_input_2);
			`BGZ_OP: condition_bit = (alu_input_1 > 0);
			`BLZ_OP: condition_bit = (alu_input_1 < 0);
			default: alu_output = alu_output;
			endcase
		end
	end

	/*always @(func_code or alu_input_1 or alu_input_2) begin
		case (func_code)
		`FUNC_ADD: begin
			alu_output = alu_input_1 + alu_input_2;
		end
		`FUNC_SUB: begin
			alu_output = alu_input_1 - alu_input_2;
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
	end*/
endmodule