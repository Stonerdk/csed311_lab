`timescale 1ns/1ns

`include "datapath.v"

module cpu(clk, reset_n, mem_signal, mem_data1, mem_data2, read_m1, read_m2, write_m2, mem_address1, mem_address2, mem_write_data, num_inst, output_port, is_halted, num_hit, num_miss);

	input clk;
	input reset_n;
	input mem_signal;
	input [63:0] mem_data1;
	input [63:0] mem_data2;

	output read_m1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] mem_address1;
	output [`WORD_SIZE-1:0] mem_address2;
	output [`WORD_SIZE-1:0] mem_write_data;
	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;
	output [`WORD_SIZE-1:0] num_hit;
	output [`WORD_SIZE-1:0] num_miss;

	wire [`WORD_SIZE-1:0] cpu_address1;
	wire [`WORD_SIZE-1:0] cpu_address2;
	wire [`WORD_SIZE-1:0] wb_data1, wb_data2, cpu_data;
	wire cpu_read_m1, cpu_read_m2, cpu_write_m2;
	wire cache_stall;

	datapath main(clk, reset_n, wb_data1, wb_data2, cache_stall, cpu_read_m1, cpu_read_m2, cpu_write_m2, cpu_address1, cpu_address2, cpu_data, num_inst, output_port, is_halted);
	cache cache (
        clk, 
		reset_n,
        cpu_address1,
		cpu_address2,
        cpu_read_m1, 
        cpu_read_m2, 
        cpu_write_m2,
        mem_signal,
        mem_data1, //from memory, load
        mem_data2,
        cpu_data, //from cpu, store

        hit,
        cache_stall,
        read_m1,
        read_m2,
        write_m2,
        mem_address1,
        mem_address2,
		mem_write_data,
        wb_data1,
        wb_data2,
		num_hit,
		num_miss
    );
endmodule


