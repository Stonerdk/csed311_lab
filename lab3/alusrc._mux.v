`include "opcodes.v"

`define	NumBits	16

//alu_input_2를 register_read_data_2와 immediate 중 결정하는 MUX

module alusrc_mux(read_data_2,immediate, alu_src, alu_input_2);
input [`NumBits-1:0] read_data_2;
input [`NumBits-1:0] immediate;
input alu_src;
output [`NumBits-1:0] alu_input_2;

if(alu_src == 1) begin
    alu_input_2 = immediate;
end
else begin
    alu_input_2 = read_data_2;
end

endmodule