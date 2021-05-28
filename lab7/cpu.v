`timescale 1ns/1ns

`include "datapath.v"

module cpu(clk, reset_n, mem_signal, mem_data1, mem_data2, 
		interrupt_fromexternaldevice, br, target_address, length, bg, begin_dma,
		read_m1, read_m2, write_m2, mem_address1, mem_address2, mem_write_data, num_inst, output_port, is_halted);

	input clk;
	input reset_n;
	input mem_signal;
	input [63:0] mem_data1;
	input [63:0] mem_data2;

	//for dma
	input interrupt_fromexternaldevice;
	wire interrupt_fromexternaldevice;
	input br;
	wire br;
	
	output [`WORD_SIZE-1 :0] target_address;
	wire [`WORD_SIZE-1 :0] target_address;
	output [`WORD_SIZE-1 :0] length;
	wire [`WORD_SIZE-1 :0] length;
	output bg;
	wire bg; reg bg_;
	output begin_dma;
	wire begin_dma;
	reg begin_dma_;

	///////////////////////////////////
	output read_m1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] mem_address1;
	output [`WORD_SIZE-1:0] mem_address2;
	output [`WORD_SIZE-1:0] mem_write_data;
	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;

	wire [`WORD_SIZE-1:0] cpu_address1;
	wire [`WORD_SIZE-1:0] cpu_address2;
	wire [`WORD_SIZE-1:0] wb_data1, wb_data2, cpu_data;
	wire cpu_read_m1, cpu_read_m2, cpu_write_m2;
	wire cache_stall;


	// for dma //
	initial begin
	assign bg_ = 0;
	end
	assign length = 12;
	assign target_address = 16'he; // 아무것도 없는 memory
	assign bg = bg_;
	assign beign_dma = begin_dma_;
	always@(posedge clk) begin
		if(br) begin
			bg_ <= 1;
		end
		else begin
			bg_ <= 0;
		end
		
		if(begin_dma_ == 1) begin
			begin_dma_ <= 0;
		end
	end

	always@(posedge interrupt_fromexternaldevice) begin
		begin_dma_ <= 1;
	end


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

		bg,		// for stall when cache miss

        hit,
        cache_stall,
        read_m1,
        read_m2,
        write_m2,
        mem_address1,
        mem_address2,
		mem_write_data,
        wb_data1,
        wb_data2
    );
endmodule


