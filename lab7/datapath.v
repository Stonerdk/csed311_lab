`include "opcodes.v"
`include "register_file.v" 
`include "alu.v"
`include "control_unit.v" 
`include "branch_predictor.v"
`include "hazard.v"

module datapath(clk, reset_n, wb_data1, wb_data2, cache_stall, cpu_read_m1, cpu_read_m2, cpu_write_m2, cpu_address1, cpu_address2, cpu_data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] wb_data1;
	input [`WORD_SIZE-1:0] wb_data2; 
	input cache_stall; 

	output cpu_read_m1;
	output cpu_read_m2; 
	output cpu_write_m2; 
	output [`WORD_SIZE-1:0] cpu_address1;
	output [`WORD_SIZE-1:0] cpu_address2; 
	output [`WORD_SIZE-1:0] cpu_data; 
	output reg [`WORD_SIZE-1:0] num_inst; 
	output reg [`WORD_SIZE-1:0] output_port;
	output is_halted;

	

	/////////////////////////////////////////////////////////
	reg [`WORD_SIZE-1:0] PRE_PC;
	reg [`WORD_SIZE-1:0] IFID_PC, IFID_INSTR;
	reg [`WORD_SIZE-1:0] IDEX_PC, IDEX_REG1, IDEX_REG2, IDEX_IMM;
	reg [`WORD_SIZE-1:0] EXMEM_PC, EXMEM_ALUOUT, EXMEM_ALUIN2;
	reg [`WORD_SIZE-1:0] MEMWB_PC, MEMWB_MEMOUT, MEMWB_OUT;
	reg [`WORD_SIZE-1:0] IDEX_INSTR, EXMEM_REG2, EXMEM_INSTR, MEMWB_INSTR;
	reg IDEX_FLUSH;
	reg IDEXC_ALUSRC, IDEXC_REGWRITE, IDEXC_MEMWRITE, IDEXC_MEMREAD, IDEXC_MEMTOREG, IDEXC_PCTOREG, IDEXC_WWD, IDEXC_NEWINST, IDEXC_ALU, IDEXC_HALTED, IDEXC_AVAILABLE, IDEXC_USERS, IDEXC_USERT;
	reg [1:0] IDEXC_REGDST;
	reg [3:0] IDEXC_ALUOP;
	reg EXMEMC_MEMWRITE, EXMEMC_MEMREAD, EXMEMC_REGWRITE, EXMEMC_MEMTOREG, EXMEMC_PCTOREG, EXMEMC_WWD, EXMEMC_NEWINST, EXMEMC_HALTED, EXMEMC_AVAILABLE;
	reg MEMWBC_PCTOREG, MEMWBC_WWD, MEMWBC_NEWINST, MEMWBC_MEMTOREG, MEMWBC_REGWRITE, MEMWBC_HALTED, MEMWBC_AVAILABLE;
	reg [1:0] IDEX_RS, IDEX_RT, IDEX_RDEST, EXMEM_RDEST, MEMWB_RDEST; 

	wire c_alusrc, c_memwrite, c_regwrite, c_memread, c_memtoreg, c_jr, c_pctoreg, c_wwd, c_newinst, c_branch, c_alu, c_halted, c_available, c_users, c_usert, c_id_users, c_id_usert;
	wire [3:0] c_aluop;
	wire [1:0] c_pcsrc, c_regdst;

	wire [`WORD_SIZE-1:0] actual_next_pc, next_PC;
	wire is_flush;

	wire [`WORD_SIZE-1:0] id_next_pc, id_next_pc_branch, id_next_pc_jmp, id_next_pc_jalr;
	wire [`WORD_SIZE-1:0] id_instruction, id_immediate, id_reg1, id_reg2;
	wire [`WORD_SIZE-1:0] id_bj_input1, id_bj_input2;
	wire [3:0] id_instr_opcode;
	wire [1:0] id_instr_rs;
	wire [1:0] id_instr_rt;
	wire [1:0] id_instr_rd;
	wire [1:0] id_rdest;
	wire [5:0] id_instr_func;
	wire [11:0] id_instr_jmp;
	wire [1:0] id1_sel;
	wire [1:0] id2_sel;
	
	wire id_bcond;
	wire ex_datahazard, id_datahazard, datahazard;

	wire [`WORD_SIZE-1:0] ex_alu_input1;
	wire [`WORD_SIZE-1:0] ex_alu_input2;
	wire [`WORD_SIZE-1:0] ex_alu_output;
	wire [1:0] ex_alu_sel1;
	wire [1:0] ex_alu_sel2;
	wire [`WORD_SIZE-1:0] ex_alu2_temp;
	wire [`WORD_SIZE-1:0] ex_writedata;

	wire [`WORD_SIZE-1:0] wb_writedata;

	assign cpu_address1 = PRE_PC;
	assign id_instruction = IFID_INSTR;
	assign id_instr_opcode = id_instruction[15:12];
	assign id_instr_rs = id_instruction[11:10];
	assign id_instr_rt = id_instruction[9:8];
	assign id_instr_rd = id_instruction[7:6];
	assign id_instr_func = id_instruction[5:0];
	assign id_instr_jmp = id_instruction[11:0];
	assign id_immediate[7:0] = id_instruction[7:0];
	assign id_immediate[15:8] = id_instruction[7] == 1 ? 8'hff : 8'h00;
	
	assign cpu_data = cpu_write_m2 ? EXMEM_REG2 : 16'bz;
	assign cpu_address2 = reset_n ? EXMEM_ALUOUT : 0;
	assign cpu_read_m1 = 1;
	assign cpu_read_m2 = reset_n && EXMEMC_MEMREAD;
	assign cpu_write_m2 = reset_n && EXMEMC_MEMWRITE;
	assign is_halted = MEMWBC_HALTED;

	assign c_available = (id_instruction != 0);
	assign c_newinst = !(id_datahazard || ex_datahazard || is_flush);

	assign ex_writedata = EXMEMC_PCTOREG ? EXMEM_PC + 1 : EXMEM_ALUOUT;
	assign wb_writedata = MEMWBC_PCTOREG ? MEMWB_PC + 1 : MEMWB_OUT;

	assign id_rdest = c_regdst == 0 ? id_instr_rd : c_regdst == 1 ? id_instr_rt : 2;

	assign id_bj_input1 = id1_sel == 2'b01 ? wb_writedata :
						  id1_sel == 2'b10 ? ex_writedata : id_reg1;
	assign id_bj_input2 = id2_sel == 2'b01 ? wb_writedata :
						  id2_sel == 2'b10 ? ex_writedata : id_reg2;

	assign id_next_pc_branch = id_bcond ? IFID_PC + id_immediate + 1 : IFID_PC + 1;
	assign id_next_pc = IFID_PC + 1;
	assign id_next_pc_jmp[11:0] = id_instr_jmp;
	assign id_next_pc_jmp[15:12] = 4'h0;
	assign id_next_pc_jalr = id_bj_input1;
	
	assign datahazard = id_datahazard || ex_datahazard;

	assign actual_next_pc = (PRE_PC == 0 || IDEX_FLUSH) ? PRE_PC : 
							c_pcsrc == 1 ? id_next_pc_branch :
							c_pcsrc == 2 ? id_next_pc_jmp :
							c_pcsrc == 3 ? id_next_pc_jalr : id_next_pc;
	assign is_flush = PRE_PC != actual_next_pc;

	assign ex_alu2_temp = IDEXC_ALUSRC ? IDEX_IMM : IDEX_REG2;
	assign ex_alu_input1 = ex_alu_sel1 == 2'b01 ? wb_writedata :
						   ex_alu_sel1 == 2'b10 ? ex_writedata : IDEX_REG1;
	assign ex_alu_input2 = ex_alu_sel2 == 2'b01 ? wb_writedata :
						   ex_alu_sel2 == 2'b10 ? ex_writedata : ex_alu2_temp;


	control_unit unit_control(id_instr_opcode, id_instr_func, c_available, clk, reset_n, c_branch, c_regdst, c_aluop, c_alusrc, 
	c_memwrite, c_memread, c_memtoreg, c_pcsrc, c_pctoreg, c_halted, c_wwd, c_regwrite, c_alu, c_jr, c_users, c_usert, c_id_users, c_id_usert);
	register_file unit_register(id_reg1, id_reg2, id_instr_rs, id_instr_rt, MEMWB_RDEST, wb_writedata, MEMWBC_REGWRITE, clk, reset_n);
	branch_predictor unit_bp(clk, reset_n, PRE_PC, is_flush, id_bcond, id_datahazard, c_branch, c_pcsrc[1], actual_next_pc, IFID_PC, next_PC);
	branch_alu unit_branch_alu(id_bj_input1, id_bj_input2, id_instr_opcode, id_bcond);
	hazard_detect unit_hazard(id_instr_rs, id_instr_rd, c_jr, c_branch, c_users, c_usert, IDEXC_MEMREAD, EXMEMC_MEMREAD, 
		IDEX_RDEST, IDEXC_REGWRITE, EXMEM_RDEST, EXMEMC_REGWRITE, ex_datahazard, id_datahazard);	
	alu unit_alu(ex_alu_input1, ex_alu_input2, IDEXC_ALUOP,ex_alu_output);
	forwarding forwarding_unit(IDEX_RS, IDEX_RT, id_instr_rs, id_instr_rt, c_id_users, c_id_usert, IDEXC_USERS, IDEXC_USERT, 
		EXMEM_RDEST, MEMWB_RDEST, EXMEMC_REGWRITE, MEMWBC_REGWRITE, ex_alu_sel1, ex_alu_sel2, id1_sel, id2_sel);

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
			IDEX_FLUSH <= 0;

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
			IDEXC_AVAILABLE <= 0;
			IDEXC_USERS <= 0;
			IDEXC_USERT <= 0;

			EXMEMC_MEMWRITE <= 0;
			EXMEMC_MEMREAD <= 0;
			EXMEMC_MEMTOREG <= 0;
			EXMEMC_PCTOREG <= 0;
			EXMEMC_REGWRITE <= 0;
			EXMEMC_WWD <= 0;
			EXMEMC_NEWINST <= 0;
			EXMEMC_HALTED <= 0;
			EXMEMC_AVAILABLE <= 0;

			MEMWBC_MEMTOREG <= 0;
			MEMWBC_PCTOREG <= 0;
			MEMWBC_REGWRITE <= 0;
			MEMWBC_WWD <= 0;
			MEMWBC_NEWINST <= 0;
			MEMWBC_HALTED <= 0;
			MEMWBC_AVAILABLE <= 0;
		end
		else begin
			if (!cache_stall) begin	
				if (!datahazard) begin
					PRE_PC <= next_PC;
					IFID_PC <= PRE_PC;
					IFID_INSTR <= (is_flush) ? 16'h0000 : wb_data1;
				end

				IDEX_RS <= datahazard ? 0 : id_instr_rs;
				IDEX_RT <= datahazard ? 0 : id_instr_rt;
				IDEX_RDEST <= datahazard ? 0 : id_rdest;
				IDEX_IMM <= datahazard ? 0 : id_immediate;
				IDEX_REG1 <= datahazard ? 0 : id_reg1;
				IDEX_REG2 <= datahazard ? 0 : id_reg2;
				IDEX_PC <= datahazard ? 0 : IFID_PC;
				IDEX_INSTR <= datahazard ? 0 : IFID_INSTR;
				IDEX_FLUSH <= datahazard ? 0 : is_flush;

				IDEXC_REGDST <= datahazard ? 0 : c_regdst;
				IDEXC_ALUOP <= datahazard ? 0 : c_aluop;
				IDEXC_ALUSRC <= datahazard ? 0 : c_alusrc;
				IDEXC_MEMWRITE <= datahazard ? 0 : c_memwrite;
				IDEXC_MEMREAD <= datahazard ? 0 : c_memread;
				IDEXC_MEMTOREG <= datahazard ? 0 : c_memtoreg;
				IDEXC_PCTOREG <= datahazard ? 0 : c_pctoreg;
				IDEXC_REGWRITE <= datahazard ? 0 : c_regwrite;
				IDEXC_WWD <= datahazard ? 0 : c_wwd;
				IDEXC_NEWINST <= datahazard ? 0 : c_newinst;
				IDEXC_ALU <= datahazard ? 0 : c_alu;
				IDEXC_HALTED <= datahazard ? 0 : c_halted;
				IDEXC_AVAILABLE <= datahazard ? 0 : c_available;
				IDEXC_USERS <= datahazard ? 0 : c_users;
				IDEXC_USERT <= datahazard ? 0 : c_usert;
			

				EXMEM_ALUOUT <= ex_alu_output;
				EXMEM_ALUIN2 <= ex_alu_input2;
				EXMEM_RDEST <= IDEX_RDEST;
				EXMEM_PC <= IDEX_PC;
				EXMEM_INSTR <= IDEX_INSTR;
				EXMEM_REG2 <= IDEX_REG2;

				EXMEMC_MEMWRITE <= IDEXC_MEMWRITE;
				EXMEMC_MEMREAD <= IDEXC_MEMREAD;
				EXMEMC_MEMTOREG <= IDEXC_MEMTOREG;
				EXMEMC_PCTOREG <= IDEXC_PCTOREG;
				EXMEMC_REGWRITE <= IDEXC_REGWRITE;
				EXMEMC_WWD <= IDEXC_WWD;
				EXMEMC_NEWINST <= IDEXC_NEWINST;
				EXMEMC_HALTED <= IDEXC_HALTED;
				EXMEMC_AVAILABLE <= IDEXC_AVAILABLE;

				MEMWB_MEMOUT <= wb_data2;
				MEMWB_OUT <= EXMEMC_MEMTOREG ? wb_data2 : EXMEM_ALUOUT;
				MEMWB_RDEST <= EXMEM_RDEST;
				MEMWB_PC <= EXMEM_PC;
				MEMWB_INSTR <= EXMEM_INSTR;

				MEMWBC_MEMTOREG <= EXMEMC_MEMTOREG;
				MEMWBC_PCTOREG <= EXMEMC_PCTOREG;
				MEMWBC_REGWRITE <= EXMEMC_REGWRITE;
				MEMWBC_WWD <= EXMEMC_WWD;
				MEMWBC_NEWINST <= EXMEMC_NEWINST;
				MEMWBC_HALTED <= EXMEMC_HALTED;
				MEMWBC_AVAILABLE <= EXMEMC_AVAILABLE;

			end
			else begin
				MEMWBC_NEWINST <= 0;
			end
			

			if (MEMWBC_NEWINST)
				num_inst <= num_inst + 1;
			if (MEMWBC_WWD)
				output_port <= MEMWB_OUT;
		end
	end

endmodule

