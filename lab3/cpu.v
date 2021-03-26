`include "opcodes.v" 	   
`include "alu.v"
`include "sign_extender.v"
`include "mux.v"

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;			

	reg[`WORD_SIZE-1:0] instruction;

	wire[`WORD_SIZE-1:0] read_out1;
	wire[`WORD_SIZE-1:0] read_out2;
	wire[`WORD_SIZE-1:0] alu_reg_result;
	wire[`WORD_SIZE-1:0] alu_imm_result;
	wire[`WORD_SIZE-1:0] write_data;

	wire[`WORD_SIZE-1:0] extended_immediate;
	
	wire[1:0] register_write_reg;
	wire control_reg_write;
	wire control_alu_src;
    wire control_mem_to_reg;
    wire control_jp;
    wire control_branch;
	
	control_unit unit_control_unit(
		.instr(data), 
		.alu_src(control_alu_src), 
		.reg_write(control_reg_write), 
		.mem_read(readM), 
		.mem_to_reg(control_mem_to_reg), 
		.mem_write(writeM), 
		.jp(control_jp), 
		.branch(control_branch)
	);
	mux unit_mux_register_write_reg(
		.in1(instruction[9:8]),
		.in0(instruction[7:6]),
		.out(register_write_reg),
		.control(control_alu_src)
	);
	register_file unit_register_file(
		.read_out1(read_out1), 
		.read_out2(read_out2), 
		.read1(inst  ruction[11:10]), 
		.read2(instruction[9:8]), 
		.write_reg(register_write_reg), 
		.write_data(write_data), 
		.reg_write(control_reg_write), 
		clk(clk), 
		reset_n(reset_n));
	alu unit_alu(
		.alu_input1(read_out1), 
		.alu_input2(read_out2), 
		.func_code(instruction[5:0]), 
		.alu_output(alu_reg_result));
	immediate_alu unit_immediate_alu(
		.alu_input_reg(read_out1),
		.alu_input_imm(extended_immediate),
		.alu_output(alu_imm_result),
		.opcode(instruction[15:12])
	);	
	sign_extender unit_sign_extender(
		.in(instruction[7:0]),
		.out(extended_immediate));
	mux mux_alu_src(
		.in0(alu_reg_result),
		.in1(alu_imm_result),
		.control(control_alu_src),
		.out(write_data)
	);

endmodule							  																		  