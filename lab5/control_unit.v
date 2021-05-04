
// IF/ID 직후에 control 값을 생성함.
// 이후에 mux에서 이 control 값드링 모두 0으로 flush 될 지를 결정.


module control_unit (opcode, func_code, clk, reset_n, pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op);

	input [3:0] opcode;
	input [5:0] func_code;
	input clk;
	input reset_n;

	output reg branch, reg_dst[1:0], alu_op, alu_src, mem_write, mem_read, mem_to_reg, pc_src;
  	output reg pc_to_reg /*JALR, JAL*/, halt, wwd, new_inst;
  	output reg [1:0] reg_write;

	branch = opcode == 0 || opcode == 1 || opcode == 2 || opcode == 3; //BNE, BEQ, BGZ, BlZ	
	//00 -> rs, 01 -> rt, 10 -> 2
	reg_dst[1] = opcode == 10 || (opcode == 15 && func_code == 26); //JAL, JRL
	reg_dst[0] = opcode == 4 || opcode == 5 || opcode == 6 || opcode == 7; //ADI< ORI, LHI, LWD
	
	//alu_op = 0; // TODO
	//alu_op = J-type ? 0 : 1;

	alu_src = (opcode != 15); // I-Type
	mem_write = opcode == 8;
	mem_read = opcode == 7;
	mem_to_reg = opcode == 7;
	pc_to_reg = reg_dst[1];
	// 00 : pc+1, 01 : pc+1+imm(branch), 10 : imm (jmp, jal), 11 : rs (jpr, jrl)
	wire jpr_jrl;
	jal_jrl = opcode == 15 && (func_code == 25 || func_code == 26);
	pc_src[1] = opcode == 9 || opcode == 10 || jpr_jrl; //JMP, JAL, JPR, JRL
	pc_src[0] = opcode == 0 || opcode == 1 || opcode == 2 || opcode == 3 || jpr_jrl; //bne, beq, bgz, blz, jpr, jrl

	halt = opcode == 15 && func_code == 29;
	wwd = opcode == 15 && func_code == 28;
	new_inst = 1; 
	reg_write = (opcode == 15 && (func_code == 0 || func_code == 1 || func_code == 2 || func_code == 3 || func_code == 4 || func_code == 5 || func_code == 6 || func_code == 7 || func_code == 26))
				|| opcode == 4 || opcode == 5 || opcode == 6 || opcode = 7 || opcode == 10;
				//(add, sub, and, orr, not, tcp shl, shr), adi, ori, lhi, lwd, jal, jrl


	
	//TODO : implement control unit

endmodule