module sign_extender(in, out);
input reg[7:0] in;
output reg[15:0] out;
begin
    assign out[7:0] = in[7:0];
    assign out[15:8] = in[7] ? 8'b11111111 : 8'b0;
    // TODO
end