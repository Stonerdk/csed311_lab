`include "opcodes.v"

module branch_ID(A,B,branch_type);

input [`WORD_SIZE -1 : 0] A;
input [`WORD_SIZE - 1: 0] B;
input [2:0] brach_type;

output bcond;

@always(*) begin
    case (branch_type)
           `bt_ne: bcond = (A != B);
           `bt_eq: bcond = (A == B);
           `bt_gz: bcond = (A[15] != 1'b1) && ( A != 16'd0);
           `bt_lz: bcond = (A[15] == 1'b1);
           `none: bcond = 0;
           default : bcond = 0;
    endcase
end

endmodule