`include "opcodes.v" 

module alu (A, B, func_code, branch_type, alu_out, overflow_flag, bcond);

	input [`WORD_SIZE-1:0] A;
	input [`WORD_SIZE-1:0] B;
	input [2:0] func_code;
	input [1:0] branch_type; 

	output reg [`WORD_SIZE-1:0] alu_out;
	output reg overflow_flag; 
	output reg bcond;

	//TODO: implement alu 
   always @(*) begin
      case (func_code)
         `ac_add: C = A + B;
         `ac_and: C = A & B;
         `ac_orr: C = A | B;
         `ac_sub: C = A - B;
         `ac_not: C = ~A;
         `ac_tcp: C = ~A + 1;
         `ac_shl: C = A << 1;
         `ac_shr: C = A >> 1;
         `ac_lhi: C = B << 8;
         `ac_wwd: C = A;
         `ac_jmp: C = B;
         `ac_jr: C = A;
         `ac_branch: 
            case (branch_type)
               `bt_ne: bcond = (A != B);
               `bt_eq: bcond = (A == B);
               `bt_gz: bcond = (A[15] != 1'b1) && ( A != 16'd0);
               `bt_lz: bcond = (A[15] == 1'b1);
            endcase
      endcase
      
      overflow_flag = 
         func_code == `ac_add ? (A[15] && B[15] && ~C[15] || ~A[15] && ~B[15] && C[15]) :
         func_code == `ac_sub ? (A[15] && ~B[15] && ~C[15] || ~A[15] && B[15] && C[15]) : 0;
   end	

endmodule