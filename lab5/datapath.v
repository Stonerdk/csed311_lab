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
	
	reg [`WORD_SIZE-1:0] IFID_PC;
	reg [`WORD_SIZE-1:0] IFID_INSTR;

	reg [`WORD_SIZE-1:0] IDEX_REG1;
	reg [`WORD_SIZE-1:0] IDEX_REG2;
	reg [`WORD_SIZE-1:0] IDEX_IMM;
	reg [1:0] IDEX_RS;
	reg [1:0] IDEX_RT;
	reg [1:0] IDEX_RDEST; 
	reg IDEXC_REGDST;
	reg IDEXC_ALUOP;
	reg IDEXC_ALUSRC;
	reg IDEXC_MEMWRITE;
	reg IDEXC_MEMREAD;
	reg IDEXC_MEMTOREG;
	reg IDEXC_PCTOREG;
	reg IDEXC_REGWRITE;
	reg IDEXC_WWD;
	reg IDEXC_NEWINST;

	reg [`WORD_SIZE-1:0] EXMEM_ALUOUT;
	reg [`WORD_SIZE-1:0] EXMEM_ALUIN2;
	reg [1:0] EXMEM_RDEST;
	reg EXMEMC_MEMWRITE;
	reg EXMEMC_MEMREAD;
	reg EXMEMC_MEMTOREG;
	reg EXMEMC_PCTOREG;
	reg EXMEMC_REGWRITE;
	reg EXMEMC_WWD;
	reg EXMEMC_NEWINST;

	reg [`WORD_SIZE-1:0] MEMWB_MEMOUT;
	reg [`WORD_SIZE-1:0] MEMWB_ALUOUT;
	reg [1:0] MEMWB_RDEST;
	reg MEMWBC_MEMTOREG;
	reg MEMWBC_PCTOREG;
	reg MEMWBC_REGWRITE;
	reg MEMWBC_WWD;
	reg MEMWBC_NEWINST;

	wire [`WORD_SIZE-1:0] id_next_pc;
	wire [`WORD_SIZE-1:0] id_next_pc_branch;
	wire [`WORD_SIZE-1:0] id_next_pc_jmp;
	wire [`WORD_SIZE-1:0] id_next_mp_jalr;
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
	assign wb_writedata = memread ? MEMWB_MEMOUT : MEMWB_ALUOUT; // todo
	register_file unit_register(
		.read_out1(id_reg1), 
		.read_out2(id_reg2), 
		.read1(id_instr_rs), 
		.read2(id_instr_rt), 
		.dest(MEMWB_RDEST), //todo 
		.write_data(wb_writedata), //todo
		.reg_write(), //todo 
		.clk(clk), 
		.reset_n(reset_n)
	);

	alu unit_alu(
		.A(ex_alu_input1), 
		.B(ex_alu_input2), 
		.func_code(), //todo
		.branch_type(), //todo
		.alu_out(ex_alu_output), 
		.overflow_flag(), //todo
		.bcond() //todo
	);

	//TODO: implement datapath of pipelined CPU
	always @(posedge clk) begin
		IFID_PC <= ifid_next_pc;
		IFID_INSTR <= data1;

		IDEX_RS <= ifid_instr_rs;
		IDEX_RT <= ifid_instr_rt;
		IDEX_RDEST <= Rtype ? ifid_instr_rd : Itype ? ifid_instr_rt : JALR ? 2; //todo
		IDEX_IMM <= ifid_immediate;
		IDEX_REG1 <= ifid_reg1;
		IDEX_REG2 <= ifid_reg2;

		EXMEM_ALUOUT <= ex_alu_output;
		EXMEM_ALUIN2 <= ex_alu_input2;
		EXMEM_RDEST <= IDEX_RDEST;

		MEMWB_MEMOUT <= data2;
		MEMWB_ALUOUT <= EXMEM_ALUOUT;
		MEMWB_RDEST <= EXMEM_RDEST;

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
	end
	
	//
endmodule

