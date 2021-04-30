`include "opcodes.v"
`include "register.v" 
`include "alu.v"
`include "control_unit.v" 
`include "branch_predictor.v"
`include "hazard.v"

module datapath(clk, reset_n, read_m1, address1, data1, read_m2, write_m2, address2, data2, num_inst, output_port, is_halted);

	input clk;
	input reset_n;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;

	output reg [`WORD_SIZE-1:0] num_inst;
	output reg [`WORD_SIZE-1:0] output_port;
	output is_halted;

	//TODO: implement datapath of pipelined CPU
	wire control_pc_write_cond;
	wire control_pc_write;
	wire control_i_or_d;
	wire control_mem_read;
	wire control_ir_write; 
	wire control_pc_src; 
	wire control_mem_to_reg; 
	wire control_mem_write;
	wire control_pc_to_reg; 
	wire control_halt; 
	wire control_wwd; 
	wire control_new_inst;
	wire control_pc_temp_write;
	wire [1:0] control_reg_write;
	wire control_alu_src_A; 
	wire [1:0] control_alu_src_B;
	wire control_alu_op;
	wire pc_update;


	reg [15:0] PC;
	reg [15:0] INSTR;
	reg [15:0] MEMDATA;
	reg [15:0] REG_A;
	reg [15:0] REG_B;
	reg [15:0] ALU_OUT;
	reg [15:0] NUM_INST;
	reg [15:0] OUTPUT_PORT;
	reg [15:0] REG_PC_TEMP;
	reg WRITE_M;
	reg READ_M;

	control_unit u2(
		.reset_n(reset_n),
		.opcode(INSTR[15:12]), 
		.func_code(INSTR[5:0]), 
		.clk(clk), 
		.pc_temp_write(control_pc_temp_write),
		.pc_write_cond(control_pc_write_cond), 
		.pc_write(control_pc_write), 
		.i_or_d(control_i_or_d), 
		.mem_read(control_mem_read), 
		.mem_to_reg(control_mem_to_reg),
		.mem_write(control_mem_write), 
		.ir_write(control_ir_write), 
		.pc_to_reg(control_pc_to_reg), 
		.pc_src(control_pc_src), 
		.halt(control_halt), 
		.wwd(control_wwd), 
		.new_inst(control_new_inst), 
		.reg_write(control_reg_write), 
		.alu_src_A(control_alu_src_A), 
		.alu_src_B(control_alu_src_B), 
		.alu_op(control_alu_op)
	);


	register_file reg_unit(
		.read_out1(), 
		.read_out2(), 
		.read1(), 
		.read2(), 
		.dest(), 
		.write_data(), 
		.reg_write(), 
		.clk(clk), 
		.reset_n(reset_n)
	)

endmodule

