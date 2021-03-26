`include "opcodes.v"
module mux_2bit(in1, in0, control, out) begin
    input [1:0] in1;
    input [1:0] in0;
    input control;
    output [1:0] out;
    assign out = control ? in1 : in0;
end