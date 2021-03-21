`include "opcodes.v" 	   

module control_unit (instr, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jp, branch);
    input [`WORD_SIZE-1:0] instr;
    output reg alu_src;
    output reg reg_write;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg jp;
    output reg branch;

    reg[3:0] opcode;
    reg[5:0] funccode;
    opcode = instr[`WORD_SIZE:`WORD_SIZE - 3];
    funccode = instr[5:0];
    
    reg_write = (opcode != `BNE_OP) &&
                (opcode != `BEQ_OP) &&
                (opcode != `BGZ_OP) &&
                (opcode != `BLZ_OP) &&
                (opcode != `SWD_OP);
    alu_src = (opcode == `ADI_OP) ||
              (opcode == `ORI_OP) ||
              (opcode == `LHI_OP) ||
              (opcode == `LWD_OP) ||
              (opcode == `SWD_OP) ||
              (opcode == `JMP_OP) ||
              (opcode == `JAL_OP);
    mem_read = (opcode == `LWD_OP);
    mem_write = (opcode == `SWD_OP);
    jp = (opcode == `JMP_OP) ||
         (opcode == `JAL_OP) ||
         ((opcode == `ALU_OP) && ((funccode == `INST_FUNC_JPR) || (funccode == `INST_FUNC_JRL)));
    branch = (opcode[3:2] == 0);

endmodule