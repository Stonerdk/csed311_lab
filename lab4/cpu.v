
`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

module cpu(clk, reset_n, read_m, write_m, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output read_m;
	output write_m;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;		// number of INSTR executed (for testing purpose)
	output [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" INSTR
	output is_halted;

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

	wire [1:0] reg_write_port;
	wire [3:0] alu_funcCode;
	wire [1:0] alu_branchtype;
	wire bcond;
	wire overflow_flag;

	wire [15:0] memory_address_input;
	wire [15:0] reg_write_data;
	wire [15:0] reg_write_middle;
	wire [15:0] reg_out1; 
	wire [15:0] reg_out2;
	wire [15:0] alu_input1;
	wire [15:0] alu_input2;
	wire [15:0] alu_output;
	wire [15:0] immediate_extended;
	wire [15:0] immediate_j;
	wire [15:0] next_pc;

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

	// TODO : implement multi-cycle CPU
	mux2_1 m0(
		.sel(control_i_or_d),
		.i1(PC),
		.i2(ALU_OUT),
		.o(address)
	);
	mux2_1 m1(
		.sel(control_alu_src_A),
		.i1(PC),
		.i2(REG_A),
		.o(alu_input1)
	);

	mux4_1 m2(
		.sel(control_alu_src_B),
		.i1(REG_B),
		.i2(16'd1),
		.i3(immediate_extended),
		.i4(immediate_j),
		.o(alu_input2)
	);
	mux2_1 m3(
		.sel(control_mem_to_reg || control_pc_to_reg),
		.i1(ALU_OUT),
		.i2(MEMDATA),
		.o(reg_write_middle)
	);
	mux2_1 m4(
		.sel(control_pc_src),
		.i1(alu_output),
		.i2(ALU_OUT),
		.o(next_pc)
	);

	mux2_1 m5(
		.sel(control_pc_to_reg),
		.i1(reg_write_middle),
		.i2(REG_PC_TEMP),
		.o(reg_write_data)
	);
	
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
	register_file u3(
		.read_out1(reg_out1), 
		.read_out2(reg_out2), 
		.read1(INSTR[11:10]), 
		.read2(INSTR[9:8]), 
		.write_reg(reg_write_port), 
		.write_data(reg_write_data), 
		.reg_write(control_reg_write[1] | control_reg_write[0]), 
		.clk(clk)
	);
	
	alu_control_unit u4(
		.funct(INSTR[5:0]), 
		.opcode(INSTR[15:12]), 
		.ALUOp(control_alu_op), 
		.clk(clk), 
		.funcCode(alu_funcCode), 
		.branchType(alu_branchtype)
	);	

	alu u5(
		.A(alu_input1), 
		.B(alu_input2), 
		.func_code(alu_funcCode), 
		.branch_type(alu_branchtype), 
		.C(alu_output), 
		.overflow_flag(overflow_flag), 
		.bcond(bcond)
	);
	assign immediate_j[11:0] = INSTR[11:0];
	assign immediate_j[15:12] = 4'b0000;
	assign immediate_extended[7:0] = INSTR[7:0];
    assign immediate_extended[15:8] = INSTR[7] ? 8'b11111111 : 8'b0;
	assign pc_update = (control_pc_write_cond & bcond) | control_pc_write & reset_n;
	assign reg_write_port = 
		control_reg_write == 2'b10 ? INSTR[7:6] :
		control_reg_write == 2'b01 ? 2'b10 :
		control_reg_write == 2'b11 ? INSTR[9:8] : 2'b00;
	assign num_inst = NUM_INST - 1;
	assign is_halted = control_halt;
	assign read_m = control_mem_read;
	assign write_m = control_mem_write;
	assign data = write_m ? REG_B : 16'bz;
	assign output_port = OUTPUT_PORT;

	initial begin
		REG_A <= 0;
		REG_B <= 0;
		ALU_OUT <= 0;
	end

	always @(posedge clk) begin
		if (!reset_n)
		begin
			PC <= 0;
			NUM_INST <= 0;
		end
		else if (pc_update) 
			PC <= next_pc;
		if (control_ir_write) 
			INSTR <= data;
		if (control_new_inst) 
			NUM_INST <= NUM_INST + 1;
		if (control_wwd) 
			OUTPUT_PORT <= ALU_OUT;
		MEMDATA <= data;
		REG_A <= reg_out1;
		REG_B <= reg_out2;
		ALU_OUT <= alu_output;
		if (control_pc_temp_write)
			REG_PC_TEMP <= PC;
	end
endmodule
