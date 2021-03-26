`include "opcodes.v"
module adder(in0, in1, out)
input [`WORD_SIZE - 1:0] in0;
input [`WORD_SIZE - 1:0] in1;
output [`WORD_SIZE - 1:0] out;
begin
    assign out = in0 + in1;
end

