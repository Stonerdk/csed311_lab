module control_unit (opcode, func_code, is_available, clk, reset_n, branch, reg_dst, alu_op, alu_src, mem_write, mem_read, mem_to_reg, pc_src, pc_to_reg, halt, wwd, reg_write, alu, jr, use_rs, use_rt);
	input [3:0] opcode;
	input [5:0] func_code;
	input is_available;
	input clk;
	input reset_n;

	output branch, alu_src, mem_write, mem_read, mem_to_reg;
  	output pc_to_reg, halt, wwd, reg_write, alu, jr, use_rs, use_rt;
  	output [1:0] reg_dst, pc_src;
	output [3:0] alu_op;
	wire br, alui, lwd, swd, jmp, jal, jpr, jrl, rtype;

	assign rtype = opcode == 15;
	assign branch = is_available && opcode == 0 || opcode == 1 || opcode == 2 || opcode == 3;
	assign alu = rtype && ~func_code[5] && ~func_code[4] && ~func_code[3];
	assign alui = opcode == 4 || opcode == 5 || opcode == 6;
	assign lwd = opcode == 7;
	assign swd = opcode == 8;
	assign jmp = opcode == 9;
	assign jal = opcode == 10;
	assign jpr = rtype && func_code == 25;
	assign jrl = rtype && func_code == 26;
	
	assign reg_dst[1] = jal || jrl;
	assign reg_dst[0] = lwd || alui; // 00 -> rd, 01 -> rt, 10 -> 2
	assign alu_src = ~rtype;
	assign mem_write = swd;
	assign mem_read = lwd;
	assign mem_to_reg = lwd;
	assign pc_to_reg = jal || jrl;
	assign jr = jpr || jrl;
	assign pc_src[1] = jmp || jal || jr;
	assign pc_src[0] = is_available && branch || jr; //PC + 1, branch, jmp, jr
	assign wwd = rtype && func_code == 28;
	assign halt = rtype && func_code == 29; 
	assign reg_write = alu || alui || lwd || jal || jrl;
	assign alu_op = alu ? func_code[2:0] :
					(opcode == 5) ? 4'd3 :
					(opcode == 6) ? 4'd8 :
					(wwd || jpr || jrl) ? 4'd9 : 4'd0;
	assign use_rs = !(opcode == 6 || jmp || jal || halt);
	assign use_rt = rtype && !func_code[3] && !func_code[2] || mem_write || is_available && (opcode == 0 || opcode == 1); 
endmodule