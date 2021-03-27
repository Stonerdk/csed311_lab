`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, alu_op, func_code, alu_output, condition_bit);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	
	input [3:0] alu_op; 
	input [2:0] func_code;

	output reg [`NumBits-1:0] alu_output;
	output reg condition_bit; 

		initial begin 
			alu_output = 0;
			condition_bit = 0;
		end
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


endmodule