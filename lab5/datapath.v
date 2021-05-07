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

	reg [`WORD_SIZE-1:0] PC;
	reg [`WORD_SIZE-1:0] IFID_PC, IFID_INSTR;
	reg [`WORD_SIZE-1:0] IDEX_PC, IDEX_REG1, IDEX_REG2, IDEX_IMM;
	reg [`WORD_SIZE-1:0] EXMEM_PC, EXMEM_ALUOUT, EXMEM_ALUIN2;
	reg [`WORD_SIZE-1:0] MEMWB_PC, MEMWB_MEMOUT, MEMWB_OUT;
	reg IDEXC_REGDST[1:0], IDEXC_ALUOP[2:0], IDEXC_ALUSRC, IDEXC_MEMWRITE, IDEXC_MEMREAD, IDEXC_MEMTOREG;
	reg IDEXC_PCTOREG, IDEXC_REGWRITE[1:0], IDEXC_WWD, IDEXC_NEWINST;
	reg EXMEMC_MEMWRITE, EXMEMC_MEMREAD, EXMEMC_MEMTOREG, EXMEMC_PCTOREG, EXMEMC_REGWRITE[1:0], EXMEMC_WWD, EXMEMC_NEWINST;
	reg MEMWBC_PCTOREG, MEMWBC_REGWRITE[1:0], MEMWBC_WWD, MEMWBC_NEWINST;
	reg [1:0] IDEX_RS, IDEX_RT, IDEX_RDEST, EXMEM_RDEST, MEMWB_RDEST; 

	wire c_aluop [2:0], c_alusrc, c_memwrite, c_memread, c_memtoreg, c_pctoreg, c_wwd, c_newinst, c_branch;
	wire [1:0] c_pcsrc, c_regwrite, regdst;
	wire [`WORD_SIZE-1:0] id_next_pc, id_next_pc_branch, id_next_pc_jmp, id_next_mp_jalr;
	wire [3:0] id_instr_opcode;
	wire [1:0] id_instr_rs;
	wire [1:0] id_instr_rt;
	wire [1:0] id_instr_rd;
	wire [5:0] id_instr_func;
	wire [7:0] id_instr_imm;
	wire [11:0] id_instr_jmp;
	wire [`WORD_SIZE-1:0] id_immediate;
	wire [`WORD_SIZE-1:0] id_reg1;
	wire [`WORD_SIZE-1:0] id_reg2;
	wire id_bcond;
	wire id_flush;

	wire [`WORD_SIZE-1:0] ex_alu_input1;
	wire [`WORD_SIZE-1:0] ex_alu_input2;
	wire [`WORD_SIZE-1:0] ex_alu_output;

	wire [`WORD_SIZE-1:0] wb_writedata;

	assign address1 = PC;
	
	assign id_instr_opcode = id_instruction[15:12];
	assign id_instr_rs = id_instruction[11:10];
	assign id_instr_rt = id_instruction[9:8];
	assign id_instr_rd = id_instruction[7:6];
	assign id_instr_func = id_instruction[5:0];
	assign id_instr_imm = id_instruction[7:0];
	assign id_instr_jmp = id_instruction[11:0];
	assign id_immediate[7:0] = id_instr_imm;
	assign id_immediate[15:8] = id_instr_imm[7] == 1 ? 8'hff : 8'h00;

	assign id_next_pc_branch = id_immediate + IFID_PC;
	assign id_next_pc = PC + 1;
	assign id_next_pc_jmp[11:0] = id_instr_jmp;
	assign id_next_pc_jmp[15:12] = 4'h0;
	assign id_next_pc_jalr = id_reg1;

	assign data2 = write_m2 ? EXMEM_ALUIN2 : 16'bz;
	assign address2 = EXMEM_ALUOUT;
	assign read_m2 = EXMEMC_MEMREAD;
	assign write_m2 = EXMEMC_MEMWRITE;
	
	control_unit unit_control(
		opcode(id_instr_opcode), 
		func_code(id_instr_func), 
		clk(clk), 
		reset_n(reset_n), 
		branch(c_branch), 
		reg_dst(c_regdst), 
		alu_op(c_aluop), 
		alu_src(c_alusrc), 
		mem_write(c_memwrite), 
		mem_read(c_memread), 
		mem_to_reg(c_memtoreg), 
		pc_src(c_pcsrc), 
		pc_to_reg(c_pctoreg), 
		halt(is_halted), 
		wwd(c_wwd), 
		new_inst(c_newinst), 
		reg_write(c_regwrite)
	);

	assign wb_writedata = MEMWBC_PCTOREG ? MEMWB_PC : MEMWB_OUT; 
	register_file unit_register(
		.read_out1(id_reg1), 
		.read_out2(id_reg2), 
		.read1(id_instr_rs), 
		.read2(id_instr_rt), 
		.dest(MEMWB_RDEST),
		.write_data(wb_writedata),
		.reg_write(MEMWBC_REGWRITE),
		.clk(clk), 
		.reset_n(reset_n)
	);

	branch_alu unit_branch_alu(id_reg1, id_reg2, id_instr_opcode, id_bcond);
	assign id_flush = c_pcsrc[1] || c_pcsrc[0] && id_bcond;

	assign ex_alu_input2 = IDEXC_ALUSRC ? id_immediate : id_reg1;
	alu unit_alu(
		.A(ex_alu_input1), 
		.B(ex_alu_input2), 
		.func_code(IDEXC_ALUOP),
		.alu_out(ex_alu_output)
	);

	//TODO: implement datapath of pipelined CPU
	initial begin
		new_inst <= 0;
	end
	always @(posedge clk) begin
		case (c_pcsrc)
			0: IFID_PC <= id_next_pc;
			1: IFID_PC <= id_bcond ? id_next_pc_branch : id_next_pc;
			2: IFID_PC <= id_next_pc_jmp;
			3: IFID_PC <= id_next_pc_jalr;
			default: IFID_PC <= id_next_pc;
		endcase
		IFID_INSTR <= id_flush ? data1 : 0;

		IDEX_RS <= if_instr_rs;
		IDEX_RT <= if_instr_rt;
		IDEX_RDEST <= IDEXC_REGDST == 0 ? if_instr_rd : IDEXC_REGDST == 1 ? if_instr_rt : 2;
		IDEX_IMM <= if_immediate;
		IDEX_REG1 <= if_reg1;
		IDEX_REG2 <= if_reg2;
		IDEX_PC <= IFID_PC;

		EXMEM_ALUOUT <= ex_alu_output;
		EXMEM_ALUIN2 <= ex_alu_input2;
		EXMEM_RDEST <= IDEX_RDEST;
		EXMEM_PC <= IDEX_PC;

		MEMWB_MEMOUT <= data2;
		MEMWB_OUT <= TMEMWBC_MEMTOREG ? MEMWB_MEMOUT : MEMWB_ALUOUT;
		MEMWB_RDEST <= EXMEM_RDEST;
		MEMWB_PC <= EXMEM_PC;

		IDEXC_REGDST <= c_regdst;
		IDEXC_ALUOP <= c_aluop;
		IDEXC_ALUSRC <= c_alusrc;
		IDEXC_MEMWRITE <= c_memwrite;
		IDEXC_MEMREAD <= c_memread;
		IDEXC_MEMTOREG <= c_memtoreg;
		IDEXC_PCTOREG <= c_pctoreg;
		IDEXC_REGWRITE <= c_regwrite;
		IDEXC_WWD <= c_wwd;
		IDEXC_NEWINST <= c_newinst;

		EXMEMC_MEMWRITE <= IDEXC_MEMWRITE;
		EXMEMC_MEMREAD <= IDEXC_MEMREAD;
		EXMEMC_MEMTOREG <= IDEXC_MEMTOREG;
		EXMEMC_PCTOREG <= IDEXC_PCTOREG;
		EXMEMC_REGWRITE <= IDEXC_REGWRITE;
		EXMEMC_WWD <= IDEXC_WWD;
		EXMEMC_NEWINST <= IDEXC_NEWINST;

		MEMWBC_MEMTOREG <= EXMEMC_MEMTOREG;
		MEMWBC_PCTOREG <= EXMEMC_PCTOREG;
		MEMWBC_REGWRITE <= EXMEMC_REGWRITE;
		MEMWBC_WWD <= EXMEMC_WWD;
		MEMWBC_NEWINST <= EXMEMC_NEWINST;

		if (MEMWBC_NEWINST)
			new_inst <= new_inst + 1;
		if (MEMWBC_WWD)
			output_port <= MEMWB_OUT;
	end
	
	//
endmodule

