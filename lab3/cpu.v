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

	reg [`WORD_SIZE-1:0] instruction;
	reg [`WORD_SIZE-1:0] instruction_address;

	wire [1:0] if_read_reg1;
	wire [1:0] if_read_reg2;
	wire [1:0] if_write_reg;
	wire [3:0] if_opcode;
	wire [5:0] if_funccode;
	wire [7:0] if_immediate;
	wire [`WORD_SIZE - 1] extended_immediate;

	wire control_reg_write;
	wire control_mem_read;
	wire control_mem_to_reg;
	wire control_mem_write;
	wire control_jp;
	wire control_branch;

	wire [`WORD_SIZE-1:0] read_out1; 
	wire [`WORD_SIZE-1:0] read_out2;
	wire [`WORD_SIZE-1:0] reg_write_data;

	wire [`WORD_SIZE-1:0] alu_input2;
	wire [`WORD_SIZE-1:0] alu_output;

	wire condition_bit;

	assign if_read_reg1 = instruction[11:10];
	assign if_read_reg2 = instruction[9:8];
	assign if_write_reg = instruction[7:6];
	assign if_opcode = instruction[15:12];
	assign if_funccode = instruction[5:0];
	assign if_immediate = instruction[7:0];

	control_unit unit_control_unit(
		.instr(instruction), 
		.alu_src(control_alu_src), 
		.reg_write(control_reg_write), 
		.mem_read(control_mem_read), 
		.mem_to_reg(control_mem_to_reg), 
		.mem_write(control_mem_write), 
		.jp(control_jp), 
		.branch(control_branch));

	register_file unit_register_file(
		.read_out1(read_out1), 
		.read_out2(read_out2), 
		.read1(if_read_reg1), 
		.read2(if_read_reg2), 
		.write_reg(if_write_reg), 
		.write_data(reg_write_data), 
		.reg_write(control_reg_write), 
		.clk(clk), 
		.reset_n(reset_n)
	);

	alu unit_alu(
		.alu_input_1(read_out1), 
		.alu_input_2(alu_input2), 
		.alu_op(if_opcode), 
		.func_code(if_funccode), 
		.alu_output(alu_output), 
		.condition_bit(condition_bit\)
	);

	mux unit_mux_alusrc(
		.in1(extended_immediate),
		.in0(read_out2),
		.control(control_alu_src),
		.out(alu_input2)
	);

	sign_extender unit_sign_extender(
		.in(if_immediate),
		.out(extended_immediate)
	);

	alusrc_mux(read_data_2,immediate, alu_src, alu_input_2);

	


endmodule							  																		  