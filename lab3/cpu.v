`include "alu.v"
`include "control_unit.v"
`include "sign_extender.v"
`include "opcodes.v" 
`include "register_file.v"


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

	reg firsttime;

	wire[1:0] reg_input2;

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
		firsttime <= 0;
	end
	

	wire [`WORD_SIZE - 1:0] instruction_target_plus1;
	wire [`WORD_SIZE - 1:0] instruction_target_branch;
	
	assign instruction_target_plus1 = instruction_address + 16'd1;
	assign instruction_address_next = (control_jpr ? read_out1
									: control_jp ? extended_immediate
									: instruction_target_plus1) +
									((condition_bit & control_branch) ?
									extended_immediate : 0);
	assign address = clk ? instruction_address : alu_output;

	control_unit unit_control_unit(
		.instr(instruction), 
		.alu_src(control_alu_src), 
		.reg_write(control_reg_write),
		.mem_read(control_mem_read), 
		.mem_to_reg(control_mem_to_reg), 
		.mem_write(control_mem_write), 
		.jp(control_jp), 
		.jpr(control_jpr),
		.pc_to_reg(control_pc_to_reg),
		.branch(control_branch),
		.reset_n(reset_n)
		);

	assign data = writeM ? read_out2 : 16'bz;

	wire reg_write_control_bit;
	assign reg_write_control_bit = control_reg_write | control_mem_to_reg & ~clk;

	assign reg_write_data = control_mem_to_reg ? data :
							control_pc_to_reg ? instruction_address :
							alu_output;
	assign reg_input2 = control_pc_to_reg ? 2'b10 :
						control_alu_src ? if_read_reg2 :
						if_write_reg;
	register_file unit_register_file(
		.read_out1(read_out1), 
		.read_out2(read_out2), 
		.read1(if_read_reg1), 
		.read2(if_read_reg2), 
		.write_reg(reg_input2), 
		.write_data(reg_write_data), 
		.reg_write(reg_write_control_bit), 
		.clk(inputReady), 
		.reset_n(reset_n)
	);
	assign alu_input2 = control_alu_src ? extended_immediate : read_out2;
	alu unit_alu(
		.alu_input_1(read_out1), 
		.alu_input_2(alu_input2), 
		.alu_op(if_opcode), 
		.func_code(if_funccode), 
		.alu_output(alu_output), 
		.condition_bit(condition_bit)
	);

	sign_extender unit_sign_extender(
		.in(if_immediate),
		.out(extended_immediate)
	);

	always @(posedge ackOutput) begin
		writeM <= 0;
	end

	always @(posedge clk) begin  
		readM <= 1;
		if (!reset_n) begin
			instruction_address <= 0;
		end
		else if (!firsttime) begin
			instruction_address <= 0;
			firsttime <= 1;
		end
		else begin
			instruction_address <= instruction_address_next;
		end
	end

	always @(negedge clk) begin
		if (control_mem_read) begin
			readM <= 1;
		end
		if (control_mem_write) begin
			writeM <= 1;
		end
	end

	always @(posedge inputReady) begin
		readM <= 0;
		if (clk) begin
			instruction <= data;
		end
	end

endmodule							  																		  