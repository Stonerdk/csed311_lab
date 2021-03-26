`include "opcodes.v"

`define	NumBits	16

module memtoReg_mux(alu_result,mem_read_data,mem_to_reg, mux_output);
input [`NumBits-1:0] alu_result;
input [`NumBits-1:0] mem_read_data;
input mem_to_reg;
output [`NumBits-1:0] mux_output; 

if(mem_to_reg == 1) begin
    mux_output = mem_read_data;
end
else begin
    mux_output = alu_result;
end

endmodule