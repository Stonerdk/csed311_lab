`include "opcodes.v"
module mux_2bit(in1, in0, control, out);
    input [1:0] in1;
    input [1:0] in0;
    input control;
    output [1:0] out;
    begin
        assign out = control ? in1 : in0;
    end
endmodule