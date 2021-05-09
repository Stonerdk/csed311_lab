`include "opcodes.v"
`include "register_file.v" 
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

	reg [`WORD_SIZE-1:0] PRE_PC;
	reg [`WORD_SIZE-1:0] IFID_PC, IFID_INSTR;
	reg [`WORD_SIZE-1:0] IDEX_PC, IDEX_REG1, IDEX_REG2, IDEX_IMM;
	reg [`WORD_SIZE-1:0] EXMEM_PC, EXMEM_ALUOUT, EXMEM_ALUIN2;
	reg [`WORD_SIZE-1:0] MEMWB_PC, MEMWB_MEMOUT, MEMWB_OUT;
	reg [`WORD_SIZE-1:0] IDEX_INSTR, EXMEM_REG2, EXMEM_INSTR, MEMWB_INSTR;
	reg IDEXC_ALUSRC, IDEXC_REGWRITE, IDEXC_MEMWRITE, IDEXC_MEMREAD, IDEXC_MEMTOREG, IDEXC_PCTOREG, IDEXC_WWD, IDEXC_NEWINST, IDEXC_ALU, IDEXC_HALTED;
	reg [1:0] IDEXC_REGDST;
	reg [3:0] IDEXC_ALUOP;
	reg EXMEMC_MEMWRITE, EXMEMC_MEMREAD, EXMEMC_REGWRITE, EXMEMC_MEMTOREG, EXMEMC_PCTOREG, EXMEMC_WWD, EXMEMC_NEWINST, EXMEMC_HALTED;
	reg MEMWBC_PCTOREG, MEMWBC_WWD, MEMWBC_NEWINST, MEMWBC_MEMTOREG, MEMWBC_REGWRITE, MEMWBC_HALTED;
	reg [1:0] IDEX_RS, IDEX_RT, IDEX_RDEST, EXMEM_RDEST, MEMWB_RDEST; 

	wire c_alusrc, c_memwrite, c_regwrite, c_memread, c_memtoreg, c_pctoreg, c_wwd, c_newinst, c_tmp_branch, c_branch, c_alu, c_halted;
	wire [3:0] c_aluop;
	wire [1:0] c_pcsrc, c_regdst;
	wire if_stall;
	wire [`WORD_SIZE-1:0] id_next_pc, id_next_pc_branch, id_next_pc_jmp, id_next_pc_jalr;
	wire [`WORD_SIZE-1:0] id_instruction, id_immediate, id_reg1, id_reg2;
	wire [3:0] id_instr_opcode;
	wire [1:0] id_instr_rs;
	wire [1:0] id_instr_rt;
	wire [1:0] id_instr_rd;
	wire [1:0] id_rdest;
	wire [5:0] id_instr_func;
	wire [7:0] id_instr_imm;
	wire [11:0] id_instr_jmp;
	wire id_bcond;
	wire id_flush;
	wire is_jpr_stall;
	wire is_branch_stall;

	wire [`WORD_SIZE-1:0] ex_alu_input1;
	wire [`WORD_SIZE-1:0] ex_alu_input2;
	wire [`WORD_SIZE-1:0] ex_alu_output;
	wire [1:0] ex_alu_sel1;
	wire [1:0] ex_alu_sel2;

	wire [`WORD_SIZE-1:0] wb_writedata;

	assign address1 = PRE_PC;
	assign id_instruction = IFID_INSTR;
	assign id_instr_opcode = id_instruction[15:12];
	assign id_instr_rs = id_instruction[11:10];
	assign id_instr_rt = id_instruction[9:8];
	assign id_instr_rd = id_instruction[7:6];
	assign id_instr_func = id_instruction[5:0];
	assign id_instr_imm = id_instruction[7:0];
	assign id_instr_jmp = id_instruction[11:0];
	assign id_immediate[7:0] = id_instr_imm;
	assign id_immediate[15:8] = id_instr_imm[7] == 1 ? 8'hff : 8'h00;

	assign id_next_pc_branch = id_immediate + PRE_PC;
	assign id_next_pc = PRE_PC + 1;
	assign id_next_pc_jmp[11:0] = id_instr_jmp;
	assign id_next_pc_jmp[15:12] = 4'h0;
	assign id_next_pc_jalr = id_reg1;

	assign data2 = write_m2 ? EXMEM_REG2 : 16'bz;
	assign address2 = reset_n ? EXMEM_ALUOUT : 0;
	assign read_m1 = 1;
	assign read_m2 = reset_n && EXMEMC_MEMREAD;
	assign write_m2 = reset_n && EXMEMC_MEMWRITE;
	assign is_halted = MEMWBC_HALTED;

	wire c_newinst_temp;
	control_unit unit_control(
		.opcode(id_instr_opcode), 
		.func_code(id_instr_func), 
		.clk(clk), 
		.reset_n(reset_n), 
		.branch(c_tmp_branch), 
		.reg_dst(c_regdst), 
		.alu_op(c_aluop), 
		.alu_src(c_alusrc), 
		.mem_write(c_memwrite), 
		.mem_read(c_memread), 
		.mem_to_reg(c_memtoreg), 
		.pc_src(c_pcsrc), 
		.pc_to_reg(c_pctoreg), 
		.halt(c_halted), 
		.wwd(c_wwd), 
		.new_inst(c_newinst_temp), 
		.reg_write(c_regwrite),
		.alu(c_alu)
	);
	assign c_branch = (id_instruction != 0) & c_tmp_branch;
	assign wb_writedata = MEMWBC_PCTOREG ? MEMWB_PC + 1 : MEMWB_OUT; 
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
	assign is_jpr_stall = (c_pcsrc[0] && c_pcsrc[1]) && 
		(id_instr_rs == IDEX_RDEST && IDEX_INSTR != 0
		|| id_instr_rs == EXMEM_RDEST && EXMEM_INSTR != 0 
		|| id_instr_rs == MEMWB_RDEST && EXMEM_INSTR != 0);
	assign is_branch_stall = c_branch && 
		((id_instr_rs == IDEX_RDEST && IDEX_INSTR != 0)
		|| (id_instr_rs == EXMEM_RDEST && EXMEM_INSTR != 0)
		|| (id_instr_rs == MEMWB_RDEST  && MEMWB_INSTR != 0)
		|| (id_instr_rt == IDEX_RDEST  && IDEX_INSTR != 0)
		|| (id_instr_rt == EXMEM_RDEST  && EXMEM_INSTR != 0)
		|| (id_instr_rt == MEMWB_RDEST && MEMWB_INSTR != 0)
		);
	assign c_newinst = !(if_stall || is_jpr_stall || is_branch_stall || id_flush);

	wire [`WORD_SIZE-1:0] ex_alu2_temp;
	wire [1:0] ex_alu_temp_sel2;
	assign ex_alu_temp_sel2 = ex_alu_sel2 && IDEXC_ALU;
	assign ex_alu2_temp = IDEXC_ALUSRC ? IDEX_IMM : IDEX_REG2;
	assign ex_alu_input1 = ex_alu_sel1 == 2'b00 ? IDEX_REG1 :
						   ex_alu_sel1 == 2'b01 ? wb_writedata :
						   ex_alu_sel1 == 2'b10 ? EXMEM_ALUOUT : IDEX_REG1;
	assign ex_alu_input2 = ex_alu_temp_sel2 == 2'b00 ? ex_alu2_temp :
						   ex_alu_temp_sel2 == 2'b01 ? wb_writedata :
						   ex_alu_temp_sel2 == 2'b10 ? EXMEM_ALUOUT : ex_alu2_temp;
	alu unit_alu(
		.A(ex_alu_input1), 
		.B(ex_alu_input2), 
		.func_code(IDEXC_ALUOP),
		.alu_out(ex_alu_output)
	);
	assign id_rdest = c_regdst == 0 ? id_instr_rd : c_regdst == 1 ? id_instr_rt : 2;
	hazard_detect hazard_detect_unit(IFID_INSTR, IDEX_RDEST, IDEXC_MEMREAD, if_stall);
	forwarding forwarding_unit(IDEX_RS, IDEX_RT, EXMEM_RDEST, MEMWB_RDEST, EXMEMC_REGWRITE, MEMWBC_REGWRITE, ex_alu_sel1, ex_alu_sel2);

	initial begin
		
	end
	always @(posedge clk) begin
		if (!reset_n) begin
			PRE_PC <= 0;
			IFID_PC <= 0;
			num_inst <= -1;
			output_port <= 0;
			IFID_INSTR <= 16'h0000;
			IDEX_RDEST <= 0;
			IDEX_RS <= 0;
			IDEX_RT <= 0;
			IDEX_RDEST <= 0;
			IDEX_IMM <= 0;
			IDEX_REG1 <= 0;
			IDEX_REG2 <= 0;
			IDEX_PC <= 0;

			EXMEM_ALUOUT <= 0;
			EXMEM_ALUIN2 <= 0;
			EXMEM_RDEST <= 0;
			EXMEM_PC <= 0;
			EXMEM_REG2 <= 0;

			MEMWB_MEMOUT <= 0;
			MEMWB_OUT <= 0;
			MEMWB_RDEST <= 0;
			MEMWB_PC <= 0;

			IDEXC_REGDST <= 0;
			IDEXC_ALUOP <= 0;
			IDEXC_ALUSRC <= 0;
			IDEXC_MEMWRITE <= 0;
			IDEXC_MEMREAD <= 0;
			IDEXC_MEMTOREG <= 0;
			IDEXC_PCTOREG <= 0;
			IDEXC_REGWRITE <= 0;
			IDEXC_WWD <= 0;
			IDEXC_NEWINST <= 0;
			IDEXC_ALU <= 0;
			IDEXC_HALTED <= 0;

			EXMEMC_MEMWRITE <= 0;
			EXMEMC_MEMREAD <= 0;
			EXMEMC_MEMTOREG <= 0;
			EXMEMC_PCTOREG <= 0;
			EXMEMC_REGWRITE <= 0;
			EXMEMC_WWD <= 0;
			EXMEMC_NEWINST <= 0;
			EXMEMC_HALTED <= 0;

			MEMWBC_MEMTOREG <= 0;
			MEMWBC_PCTOREG <= 0;
			MEMWBC_REGWRITE <= 0;
			MEMWBC_WWD <= 0;
			MEMWBC_NEWINST <= 0;
			MEMWBC_HALTED <= 0;
		end
		else begin
			
			if (!if_stall && !is_jpr_stall && !is_branch_stall) begin
				case (c_pcsrc)
					0: PRE_PC <= id_next_pc;
					1: PRE_PC <= id_bcond ? id_next_pc_branch : id_next_pc;
					2: PRE_PC <= id_next_pc_jmp;
					3: PRE_PC <= id_next_pc_jalr;
					default: PRE_PC <= id_next_pc;
				endcase
				IFID_PC <= PRE_PC;
				IFID_INSTR <= (id_flush || is_branch_stall) ? 16'h0000 : data1;
			end
			

			if (!is_jpr_stall && !if_stall && !is_branch_stall) begin
				IDEX_RS <= id_instr_rs;
				IDEX_RT <= id_instr_rt;
				IDEX_RDEST <= id_rdest;
				IDEX_IMM <= id_immediate;
				IDEX_REG1 <= id_reg1;
				IDEX_REG2 <= id_reg2;
				IDEX_PC <= IFID_PC;
				IDEX_INSTR <= IFID_INSTR;
			end

			else begin
				IDEX_RS <= 0;
				IDEX_RT <= 0;
				IDEX_RDEST <= 0;
				IDEX_IMM <= 0;
				IDEX_REG1 <=0;
				IDEX_REG2 <= 0;
				IDEX_PC <= 0;
				IDEX_INSTR <= 16'h0000;
			end

			EXMEM_ALUOUT <= ex_alu_output;
			EXMEM_ALUIN2 <= ex_alu_input2;
			EXMEM_RDEST <= IDEX_RDEST;
			EXMEM_PC <= IDEX_PC;
			EXMEM_INSTR <= IDEX_INSTR;
			EXMEM_REG2 <= IDEX_REG2;

			MEMWB_MEMOUT <= data2;
			MEMWB_OUT <= EXMEMC_MEMTOREG ? data2 : EXMEM_ALUOUT;
			MEMWB_RDEST <= EXMEM_RDEST;
			MEMWB_PC <= EXMEM_PC;
			MEMWB_INSTR <= EXMEM_INSTR;

			if (!is_jpr_stall && !if_stall && !is_branch_stall) begin
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
				IDEXC_ALU <= c_alu;
				IDEXC_HALTED <= c_halted;
			end

			else begin
				IDEXC_REGDST <= 0;
				IDEXC_ALUOP <= 0;
				IDEXC_ALUSRC <= 0;
				IDEXC_MEMWRITE <= 0;
				IDEXC_MEMREAD <= 0;
				IDEXC_MEMTOREG <= 0;
				IDEXC_PCTOREG <= 0;
				IDEXC_REGWRITE <= 0;
				IDEXC_WWD <= 0;
				IDEXC_NEWINST <= 0;
				IDEXC_ALU <= 0;
				IDEXC_HALTED <= 0;
			end
			EXMEMC_MEMWRITE <= IDEXC_MEMWRITE;
			EXMEMC_MEMREAD <= IDEXC_MEMREAD;
			EXMEMC_MEMTOREG <= IDEXC_MEMTOREG;
			EXMEMC_PCTOREG <= IDEXC_PCTOREG;
			EXMEMC_REGWRITE <= IDEXC_REGWRITE;
			EXMEMC_WWD <= IDEXC_WWD;
			EXMEMC_NEWINST <= IDEXC_NEWINST;
			EXMEMC_HALTED <= IDEXC_HALTED;

			MEMWBC_MEMTOREG <= EXMEMC_MEMTOREG;
			MEMWBC_PCTOREG <= EXMEMC_PCTOREG;
			MEMWBC_REGWRITE <= EXMEMC_REGWRITE;
			MEMWBC_WWD <= EXMEMC_WWD;
			MEMWBC_NEWINST <= EXMEMC_NEWINST;
			MEMWBC_HALTED <= EXMEMC_HALTED;

			if (MEMWBC_NEWINST)
				num_inst <= num_inst + 1;
			if (MEMWBC_WWD)
				output_port <= MEMWB_OUT;
		end
	end
	
	//
endmodule

