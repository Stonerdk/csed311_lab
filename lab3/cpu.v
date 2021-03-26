`include "opcodes.v" 	   

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;

	reg [`WORD_SIZE-1:0] instruction = [`WORD_SIZE-1:0] address;
	reg alu_src; reg reg_write;
	reg mem_read; reg mem_write;
	reg jp; reg branch;

	reg [1:0] read1 = [11:10] instruction; reg [1:0] read2 = [9:8] instruction; 
	reg [1:0] write_reg = [7:6] instruction; //for register_file

	reg [`WORD_SIZE-1:0] read_out_1; reg [`WORD_SIZE-1:0] read_out_2;

	control_unit (instr, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jp, branch);

	register_file(read_out1, read_out2, read1, read2, write_reg, write_data, reg_write, clk, reset_n);

	alusrc_mux(read_data_2,immediate, alu_src, alu_input_2);

	alu (alu_input_1, alu_input_2, alu_op, func_code, alu_output, condition_bit);



																																					  
endmodule							  																		  