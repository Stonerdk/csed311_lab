`include "opcodes.v"

module forwarding(IDEX_rs, IDEX_rt, id_rs, id_rt, id_use_rs, id_use_rt, EXMEM_rdest, MEMWB_rdest, EXMEMC_regwrite, MEMWBC_regwrite, ALU1_sel, ALU2_sel, id1_sel, id2_sel);
	input [1:0] IDEX_rs, IDEX_rt, id_rs, id_rt, EXMEM_rdest, MEMWB_rdest; //EXMEM_rdest, MEMWB_rdest;
	input id_use_rs, id_use_rt;
	input EXMEMC_regwrite, MEMWBC_regwrite;
	output [1:0] ALU1_sel, ALU2_sel;
	output [1:0] id1_sel, id2_sel;

	assign ALU1_sel[1] = EXMEMC_regwrite && IDEX_rs == EXMEM_rdest;
	assign ALU1_sel[0] = MEMWBC_regwrite && IDEX_rs == MEMWB_rdest;
	assign ALU2_sel[1] = EXMEMC_regwrite && IDEX_rt == EXMEM_rdest;
	assign ALU2_sel[0] = MEMWBC_regwrite && IDEX_rt == MEMWB_rdest;

	assign id1_sel[1] = id_use_rs && EXMEMC_regwrite && id_rs == EXMEM_rdest;
	assign id1_sel[0] = id_use_rs && MEMWBC_regwrite && id_rs == MEMWB_rdest;
	assign id2_sel[1] = id_use_rt && EXMEMC_regwrite && id_rt == EXMEM_rdest;
	assign id2_sel[0] = id_use_rt && MEMWBC_regwrite && id_rt == MEMWB_rdest;

endmodule

module hazard_detect(id_rs, id_rt, id_jpr, id_branch, id_users, id_usert, idex_memread, exmem_memread, idex_rd, idex_rw, exmem_rd, exmem_rw, memwb_rd, memwb_rw, ex_datahazard, id_datahazard);

	input [1:0] id_rs, id_rt;
	input id_users, id_usert, id_jpr, id_branch, idex_memread, exmem_memread;
	input [1:0] idex_rd, exmem_rd, memwb_rd;
	input idex_rw, exmem_rw, memwb_rw;

	output ex_datahazard;
	output id_datahazard;
	wire ieh, emh, mwh;
	//(c_pcsrc[0] && c_pcsrc[1])
	assign ieh = (idex_rd == id_rs && id_users || idex_rd == id_rt && id_usert) && idex_rw;
	assign emh = (exmem_rd == id_rs && id_users || exmem_rd == id_rt && id_usert) && exmem_rw;
	assign mwh = (memwb_rd == id_rs && id_users || memwb_rd == id_rt && id_usert) && memwb_rw;
	assign ex_datahazard = idex_memread && ieh;
	//assign id_datahazard = (id_jpr || id_branch) && (ieh || emh || mwh);
	assign id_datahazard = (id_jpr || id_branch) && (ieh || emh && exmem_memread);
endmodule