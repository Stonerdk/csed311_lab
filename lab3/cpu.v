`include "alu.v"
`include "control_unit.v"
`include "sign_extender.v"
`include "mux.v"
`include "adder.v"
`include "mux_2bit.v"
`include "opcodes.v" 
`include "register_file.v"

// readM writeM�� �׳� ���ָ�ǰ�?
//������ input ready �� ackoutput�� ��� �����? �ǳ�.


module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output reg readM;									
	output reg writeM;								
	output reg [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									

	input clk;

	reg [`WORD_SIZE-1:0] instruction;
	reg [`WORD_SIZE-1:0] instruction_address;
	wire [`WORD_SIZE-1:0] instruction_address_next;

	wire [1:0] if_read_reg1;
	wire [1:0] if_read_reg2;
	wire [1:0] if_write_reg;
	wire [3:0] if_opcode;
	wire [2:0] if_funccode;
	wire [7:0] if_immediate;
	wire [`WORD_SIZE- 1: 0] extended_immediate;

	wire[1:0] reg_input2_1;
	wire[1:0] reg_input2_2;

	wire control_reg_write;
	wire control_mem_read;
	wire control_mem_to_reg;
	wire control_mem_write;
	wire control_jp;
	wire control_branch;
	wire control_pc_to_reg; 
	wire control_jpr;

	wire [`WORD_SIZE-1:0] read_out1; 
	wire [`WORD_SIZE-1:0] read_out2;
	wire [`WORD_SIZE-1:0] reg_write1;
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

	initial begin 
		readM <= 1;
		writeM <= 0;
		instruction_address <= 0;
		address <= 0;
	end

	always @(posedge inputReady) begin
		//if (!control_mem_to_reg)	
			instruction <= data;
	end

	always @(posedge reset_n or posedge clk or posedge control_mem_read) begin  
		if (!reset_n)
			instruction_address <= 0;
		else
			instruction_address <= instruction_address_next;

		if (!reset_n)
			address <= 0;
		else if (control_mem_read)
			address <= read_out1 + extended_immediate;
		else 
			address <= instruction_address_next;
		readM = 1;
	end

	always @(negedge clk) begin
		readM = 0;
	end

	wire [`WORD_SIZE - 1:0] instruction_target_plus1;
	wire [`WORD_SIZE - 1:0] instruction_target_branch;
	
	assign instruction_target_plus1 = instruction_address + 16'd1;
	assign instruction_target_branch = instruction_address + extended_immediate;
	assign instruction_address_next = control_jpr ? read_out1
									: control_jp ? extended_immediate
									: (condition_bit & control_branch) ? instruction_target_branch
									: instruction_target_plus1;
	assign address = control_mem_read ? read_out1 + extended_immediate : instruction_address;

	control_unit unit_control_unit(
		.instr(instruction), 
		.alu_src(control_alu_src), 
		//.reg_write(control_reg_write), 
		.mem_read(control_mem_read), 
		.mem_to_reg(control_mem_to_reg), 
		.mem_write(control_mem_write), 
		.jp(control_jp), 
		.jpr(control_jpr),
		.pc_to_reg(control_pc_to_reg),
		.branch(control_branch));

	assign readM = control_mem_read;
	//reg_write_data -> data
	assign writeM = control_mem_write;
	//data -> read_out2

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
		.condition_bit(condition_bit)
	);
	
	mux_2bit unit_mux2_write_reg_alusrc(
		.in1(if_read_reg2),
		.in0(if_write_reg),
		.control(control_alu_src),
		.out(reg_input2_1)
	);

	mux_2bit unit_mux2_write_reg_pctoreg(
		.in1(2'b10),
		.in0(reg_input2_1),
		.control(control_pc_to_reg),
		.out(reg_input2_2)
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

	//todo : write_back

	
	//	
	mux nunit_mux_write_data(
		.in0(alu_output),
		.in1(instruction_address),
		.control(control_pc_to_reg),
		.out(reg_write1)
	);

	mux nunit_mux_write_data2(
		.in0(reg_write1),
		.in1(data),
		.control(inputReady & control_mem_to_reg),
		.out(reg_write_data)
	);
	// register write data select  1. alu_output, 2. pc,  3. memory data



endmodule							  																		  