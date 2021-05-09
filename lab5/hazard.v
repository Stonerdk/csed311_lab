`include "opcodes.v"

module forwarding(IDEX_rs, IDEX_rt, EXMEM_rdest, MEMWB_rdest, EXMEMC_regwrite, MEMWBC_regwrite, ALU1_sel, ALU2_sel);
	input [1:0] IDEX_rs, IDEX_rt, EXMEM_rdest, MEMWB_rdest;
	input EXMEMC_regwrite, MEMWBC_regwrite;
	output [1:0] ALU1_sel, ALU2_sel;

	assign ALU1_sel[1] = EXMEMC_regwrite && IDEX_rs == EXMEM_rdest;
	assign ALU1_sel[0] = MEMWBC_regwrite && IDEX_rs == MEMWB_rdest;
	assign ALU2_sel[1] = EXMEMC_regwrite && IDEX_rt == EXMEM_rdest;
	assign ALU2_sel[0] = MEMWBC_regwrite && IDEX_rt == MEMWB_rdest;

endmodule

module hazard_detect(id_rs, id_rt, id_jpr, id_branch, idex_memread, idex_rd, idex_av, exmem_rd, exmem_av, memwb_rd, memwb_av, ex_datahazard, id_datahazard);

	input [1:0] id_rs, id_rt;
	input id_jpr, id_branch, idex_memread;
	input [1:0] idex_rd, exmem_rd, memwb_rd;
	input idex_av, exmem_av, memwb_av;

	output ex_datahazard;
	output id_datahazard;
	wire jpr_datahazard, branch_datahazard;
	//(c_pcsrc[0] && c_pcsrc[1])
	assign ex_datahazard = idex_memread && (idex_rd == id_rs || idex_rd == id_rt) && idex_av;
	assign jpr_datahazard = id_jpr && 
		((id_rs == idex_rd && idex_av)
		|| (id_rs == exmem_rd && exmem_av)
		|| (id_rs == memwb_rd && memwb_av));
	assign branch_datahazard = id_branch && 
		(((id_rs == idex_rd || id_rt == idex_rd)  && idex_av) ||
		((id_rs == exmem_rd || id_rt == exmem_rd)  && exmem_av) ||
		((id_rs == memwb_rd || id_rt == memwb_rd)  && memwb_av));
	assign id_datahazard = jpr_datahazard || branch_datahazard;
endmodule