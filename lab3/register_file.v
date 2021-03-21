module register_file( read_out1, read_out2, read1, read2, write_reg, write_data, reg_write, clk); 
    output [15:0] read_out1;
    output [15:0] read_out2;
    input [1:0] read1;
    input [1:0] read2;
    input [1:0] write_reg;
    input [15:0] write_data;
    input reg_write;
    input clk;

    reg [3:0] register [15:0];
    
    assign read_out1 = register[read1];
    assign read_out2 = register[read2];

    always @(posedge clk) begin
        if (reg_write == 1'b1)
            register[write_reg] = write_data;
    end
    // TODO : implement reset_n to initialization
endmodule

