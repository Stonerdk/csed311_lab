`include "opcodes.v" 

`define ms_srt 5'd;

`define ms_if 5'd;

`define ms_id 5'd;

`define ms_iex 5'd;
`define ms_rex 5'd;
`define ms_bex 5'd;

//R-type
`define ms_jr 5'd;
`define ms_jrwb 5'd;
`define ms_rwb 5'd;
`define ms_wwd 5'd;
`define ms_hlt 5'd;

//I-type
`define ms_jmp 5'd;
`define ms_jwb 5'd;
`define ms_iwb 5'd;

`define ms_lmem 5'd;
`define ms_smem 5'd;

//B-type
`define ms_hlt 5`d6;



module control_unit (opcode, func_code, clk, reset_n, pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op);

	input [3:0] opcode;
	input [5:0] func_code;
	input clk;
	input reset_n;
	

	output reg pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_src;
  	//additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
  	output reg pc_to_reg, halt, wwd, new_inst;
  	output reg [1:0] reg_write, alu_src_A, alu_src_B;
  	output reg alu_op;

	//TODO : implement control unit

	initial begin
		pc_write_cond = 0;
		pc_write = 0;
		i_or_d = 0;
		mem_read = 0;
		mem_to_reg = 0;
		mem_write = 0;
		ir_write = 0;
		pc_src = 0;

		pc_to_reg = 0;
		halt = 0;
		wwd = 0;
		new_int = 0;

		reg_write = 0;
		alu_src_A = 0;
		alu_src_B = 0;

		alu_op = 0;
	end

		assign isBex = state_reg == `ms_bex;
  		assign isRex = state_reg == `ms_rex;
  		assign isIex = state_reg == `ms_iex;
  		assign isIf = state_reg == `ms_if;
  		assign isLm = state_reg == `ms_lm;
  		assign isSm = state_reg == `ms_sm;

		assign pc_write_cond = isBex;
		/*assign pc_temp_write = state_reg == `ms_id || state_reg == `ms_iex1;*/
		
		assign pc_write = state_reg == `ms_if || state_reg == `ms_jmp || state_reg == `ms_jwb || state_reg == `ms_jr || state_reg == `ms_jrwb;
		assign i_or_d = isLm || isSm;

		assign mem_read = isIf || isLm;
		assign mem_write = isSm;
		assign mem_to_reg = state_reg == `ms_lwb;

		assign ir_write = state_reg == `ms_if;

		assign pc_src = isBex || state_reg == `ms_jmp || state_reg == `ms_jwb || state_reg == `ms_jr || state_reg == `ms_jrwb;
		assign pc_to_reg = state_reg == `ms_jwb || state_reg == `ms_jrwb;
		assign new_inst = state_reg == `ms_if;

		assign reg_write[1] = state_reg == `ms_rwb || state_reg == `ms_iwb || state_reg == `ms_lwb;
		assign reg_write[0] = state_reg == `ms_jwb || state_reg == `ms_jrwb || state_reg == `ms_iwb || state_reg == `ms_lwb;

		assign alu_src_A = isRex || isIex || isBex || isSm || isLm || state_reg == `ms_jr || state_reg == `ms_jrwb;

		assign alu_src_B[1] = state_reg == `ms_id || isIex || isSm || isLm;
		assign alu_src_B[0] = isIf || (isIex && (opcode == 9 || opcode == 10));

		assign alu_op = isRex || isIex || isBex || isLm || isSm;

		assign halt = state_reg == `ms_hlt;
		assign wwd = state_reg == `ms_wwd;		

	assign alu_op = 

	always @(*) begin
		case(state_reg)
			`ms_rst: next_state_reg = `ms_if;

			`ms_if: next_state_reg = `ms_id;

			`ms_id: next_state_reg = 
				opcode == 4'd15 ? `ms_rex :
				opcode[3:2] == 2'b00 ? `ms_bex : `ms_iex;

			`ms_rex: next_state_reg = 
        		func_code == 25 ? `ms_jr : 
        		func_code == 26 ? `ms_jrwb : 
        		func_code == 28 ? `ms_wwd :
        		func_code == 29 ? `ms_hlt : `ms_rwb;

			`ms_iex: next_state_reg = 
        		opcode == 9 ? `ms_jmp : 
        		opcode == 10 ? `ms_jwb : 
        		opcode == 7 ? `ms_lm : 
        		opcode == 8 ? `ms_sm : `ms_iwb;

			`ms_bex: next_state_reg = `ms_if;

			`ms_lmem: next_state_reg = `ms_lwb;

			`ms_jr : next_state_reg = `ms_if;
			`ms_jrwb : next_state_reg = `ms_if;
			`ms_wwd : next_state_reg = `ms_if;
			`ms_rwb : next_state_reg = `ms_if;
			`ms_jmp : next_state_reg = `ms_if;
			`ms_jwb : next_state_reg = `ms_if;
			`ms_jrwb : next_state_reg = `ms_if;
			`ms_sm : next_state_reg = `ms_if;
			`ms_iwb : next_state_reg = `ms_if;
			`ms_lwb : next_state_reg = `ms_if;

			`ms_hlt : next_state_reg = `ms_hlt;

			default: next_state_reg = `ms_hlt
	end

	always @(posedge clk) begin
    	if (!reset_n)
   			state_reg <= `ms_rst;
    	else
  	    	state_reg <= next_state_reg;
 	end



endmodule
