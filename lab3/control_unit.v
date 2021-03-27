`include "opcodes.v" 	   

module control_unit (instr, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jp, jpr, pc_to_reg, branch, reset_n);
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
    input reset_n;


    reg[3:0] opcode;
    reg[5:0] funccode;
    assign opcode = instr[15:12];
    assign funccode = instr[5:0];

    initial begin 
        alu_src = 0;
        mem_read = 0;
        mem_write = 0;
        mem_to_reg = 0;
        reg_write = 0;
        jp = 0;
        jpr = 0;
        branch = 0;
        pc_to_reg = 0;
    end 
    always @(instr) begin
        if (!reset_n) begin
            alu_src = 0;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 0;
            jp = 0;
            jpr = 0;
            branch = 0;
            pc_to_reg = 0;
        end
        else begin
            alu_src =  
                (opcode == `ADI_OP) ||
                (opcode == `ORI_OP) ||
                (opcode == `LHI_OP) ||
                (opcode == `LWD_OP) ||
                (opcode == `SWD_OP) ||
                (opcode == `JMP_OP) ||
                (opcode == `JAL_OP); 
            reg_write = 
                (opcode == `ALU_OP) || 
                (opcode == `ORI_OP) || 
                (opcode == `ADI_OP) ||
                (opcode == `LHI_OP);
            mem_read = (opcode == `LWD_OP); 
            mem_write =  (opcode == `SWD_OP); 
            mem_to_reg =  (opcode == `LWD_OP);

            jp = 
                (opcode == `JMP_OP) || 
                (opcode == `JAL_OP);
            jpr =  
                (opcode == `JPR_OP & funccode == `INST_FUNC_JPR) || 
                (opcode == `JRL_OP & funccode == `INST_FUNC_JRL);
            branch = 
                (opcode == `BNE_OP) ||
                (opcode == `BEQ_OP) ||
                (opcode == `BLZ_OP) ||
                (opcode == `BGZ_OP);
            pc_to_reg =
                (opcode == `JAL_OP) || 
                (opcode == `JRL_OP & funccode == `INST_FUNC_JRL);  
        end  
    end
    
    
endmodule