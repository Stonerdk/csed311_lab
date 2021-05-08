`include "opcodes.v"

module forwarding(IDEX_rs, IDEX_rt, EXMEM_rdest, MEMWB_rdest, EXMEMC_regwrite, MEMWBC_regwrite, ALU1_sel, ALU2_sel);
	input [1:0] IDEX_rs, IDEX_rt, EXMEM_rdest, MEMWB_rdest;
	input EXMEMC_regwrite, MEMWBC_regwrite;
	output [1:0] ALU1_sel, ALU2_sel;

	assign ALU1_sel[1] = EXMEMC_regwrite && IDEX_rs == EXMEM_rdest;
	assign ALU1_sel[0] = MEMWBC_regwrite && IDEX_rs == MEMWB_rdest;
	assign ALU2_sel[1] = EXMEMC_regwrite && IDEX_rt == EXMEM_rdest;
	assign ALU2_sel[0] = MEMWBC_regwrite && IDEX_rt == EXMEM_rdest;

endmodule
module hazard_detect(IFID_IR, IDEX_rd, IDEX_M_mem_read, is_stall);

	input [`WORD_SIZE-1:0] IFID_IR;
	input [1:0]  IDEX_rd;
	input IDEX_M_mem_read;

	output is_stall;

	assign is_stall = IDEX_M_mem_read && (IDEX_rd == IFID_IR[11:10] || IDEX_rd == IFID_IR[9:8]);
	//TODO: implement hazard detection unit

endmodule