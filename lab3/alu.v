`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, alu_op, func_code, alu_output, condition_bit);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	
	input [4:0] alu_op; //opcode를 갖고옴.
	input [2:0] func_code;

	output reg [`NumBits-1:0] alu_output;
	output condition_bit; // 조건 비교를 통해 조건을 만족하는지 비트를 보냄

	if (alu_op == `ALU_OP) begin
		case(func_code)
		`FUNC_ADD: alu_output = alu_input_1 + alu_input_2;
		`FUNC_SUB: alu_output = alu_input_1 - alu_input_2;		 
		`FUNC_AND: alu_output = alu_input_1 & alu_input_2;
		`FUNC_ORR: alu_output = alu_input_1 | alu_input_2;								     
		`FUNC_NOT: alu_output = ~alu_input_1;
		`FUNC_TCP: alu_output = ~alu_input_1 + 1;
		`FUNC_SHL: alu_output = alu_input_1 << 1;
		`FUNC_SHR: alu_output = alu_input_1 >> 1;	
		default: 
		endcase
	end
	else begin
		case(alu_op)
		`ADI_OP: alu_output = alu_output_1 + alu_output_2;
		`ORI_OP: alu_output = alu_input _1 | alu_output_2;
		`LHI_OP: alu_output = alu_input_2 << 8;
		`LWD_OP: alu_output = alu_input_1 + alu_input_2; 		  
		`SWD_OP: alu_output = alu_input_1 + alu_input_2;
		`BNE_OP: condition_bit = (alu_input_1 != alu_input_2);
		`BEQ_OP: condition_bit = (alu_input_1 == alu_input_2);
		`BGZ_OP: condition_bit = (alu_input_1 > 0);
		`BLZ_OP: condition_bit = (alu_input_1 < 0);
		`JMP_OP
		`JAL_OP
		`JPR_OP
		`JRL_OP
		endcase
	end

endmodule