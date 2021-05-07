module control_unit (opcode, func_code, clk, reset_n, branch, reg_dst, alu_op, alu_src, mem_write, mem_read, mem_to_reg, pc_src, pc_to_reg, halt, wwd, new_inst, reg_write);
	input [3:0] opcode;
	input [5:0] func_code;
	input clk;
	input reset_n;

	output branch, alu_src, mem_write, mem_read, mem_to_reg;
  	output pc_to_reg, halt, wwd, new_inst;
  	output [1:0] reg_dst, reg_write, pc_src;
	output [2:0] alu_op;
	wire br, alu, alui, lwd, swd, jmp, jal, jpr, jrl, rtype;

	assign rtype = opcode == 15;
	assign branch = ~opcode[3] & ~opcode[2];
	assign alu = rtype && ~func_code[5] && ~func_code[4] && ~func_code[3];
	assign alui = opcode == 4 || opcode == 5 || opcode == 6;
	assign lwd = opcode == 7;
	assign swd = opcode == 8;
	assign jmp = opcode == 9;
	assign jal = opcode == 10;
	assign jpr = rtype && func_code == 25;
	assign jrl = rtype && func_code == 26;
	
	assign reg_dst[1] = jal || jrl;
	assign reg_dst[0] = lwd || alui;
	// 00 -> rs, 01 -> rt, 10 -> 2

	assign alu_src = ~rtype;
	assign mem_write = swd;
	assign mem_read = lwd;
	assign mem_to_reg = lwd;
	assign pc_to_reg = jal || jrl;
	
	assign pc_src[1] = jmp || jal || jpr || jrl;
	assign pc_src[0] = branch || jpr || jrl;
	// 00 : pc+1
	// 01 : pc+1+imm(branch)
	// 10 : imm (jmp, jal)
	// 11 : rs (jpr, jrl)

	assign wwd = rtype && func_code == 28;
	assign halt = rtype && func_code == 29;
	assign new_inst = 1; 
	assign reg_write = alu || alui || lwd || jal || jrl;
	assign alu_op = alu ? func_code[2:0] :
					(opcode == 5) ? 3'd3 :
					(opcode == 6) ? 3'd8 :
					(wwd || jpr || jrl) ? 3'd9 : 3'd0;

endmodule