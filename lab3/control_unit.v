`include "opcodes.v" 	   

module control_unit (instr, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jp, jpr, pc_to_reg, branch);
    input [`WORD_SIZE-1:0] instr;
    output reg alu_src;
    output reg reg_write;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg jp;
    output reg jpr;
    output reg pc_to_reg;
    output reg branch;
    begin
        reg[3:0] opcode;
        reg[5:0] funccode;
        assign opcode = instr[15:12];
        assign funccode = instr[5:0];

        assign alu_src = (opcode == `ADI_OP) ||
                (opcode == `ORI_OP) ||
                (opcode == `LHI_OP) ||
                (opcode == `LWD_OP) ||
                (opcode == `SWD_OP) ||
                (opcode == `JMP_OP) ||
                (opcode == `JAL_OP); 

        assign mem_read = (opcode == `LWD_OP); 
        assign mem_write = (opcode == `SWD_OP); 
        assign mem_to_reg = (opcode == `LWD_OP);

        assign jp = (opcode == `JMP_OP) || (opcode == `JAL_OP);
        assign jpr = (opcode == `JPR_OP) || (opcode == `JRL_OP);
        assign branch = 
            (opcode == `BNE_OP) ||
            (opcode == `BEQ_OP) ||
            (opcode == `BLZ_OP) ||
            (opcode == `BGZ_OP);
        assign pc_to_reg =
            (opcode == `JAL_OP) || (opcode == `JRL_OP);
    end
endmodule