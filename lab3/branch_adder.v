`include "opcodes.v"

`define	NumBits	16

module branch_adder(pc, imm, next_pc);
    input [`NumBits-1:0] pc;
    input [`NumBits-1:0] imm;
    output [`NumNits-1: 0] next_pc;

    next_pc = imm + pc;
endmodule