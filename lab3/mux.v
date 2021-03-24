`include "opcodes.v"
module mux(in1, in0, control, out) begin
    input [`WORD_SIZE-1:0] in1;
    input [`WORD_SIZE-1:0] in0;
    input control;
    output [`WORD_SIZE-1:0] out;
    assign out = control ? in1 : in0;
end