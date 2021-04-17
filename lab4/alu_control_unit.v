`include "opcodes.v"

module alu_control_unit(funct, opcode, ALUOp, clk, funcCode, branchType);
  input ALUOp;
  input clk;
  input [5:0] funct;
  input [3:0] opcode;

  output reg [3:0] funcCode;
  output reg [1:0] branchType;

   //TODO: implement ALU control unit

  always @(*) begin
    if (ALUOp == 0) begin
      funcCode = `ac_add;
    end
    else begin
      case (opcode)
        0: begin
          funcCode = `ac_branch;
          branchType = `bt_ne;
        end
        1: begin
          funcCode = `ac_branch;
          branchType = `bt_eq;
        end
        2: begin
          funcCode = `ac_branch;
          branchType = `bt_gz;
        end
        3: begin
          funcCode = `ac_branch;
          branchType = `bt_lz;
        end
        4: funcCode = `ac_add;
        5: funcCode = `ac_orr;
        6: funcCode = `ac_lhi;
        7: funcCode = `ac_add;
        8: funcCode = `ac_add;
        9: funcCode = `ac_jmp;
        10: funcCode = `ac_jmp;
        11: funcCode = `ac_jr;
        12: funcCode = `ac_jr;
        15: begin 
          case (funct) 
            0: funcCode = `ac_add;
            1: funcCode = `ac_sub;
            2: funcCode = `ac_and;
            3: funcCode = `ac_orr;
            4: funcCode = `ac_not;
            5: funcCode = `ac_tcp;
            6: funcCode = `ac_shl;
            7: funcCode = `ac_shr;
            28: funcCode = `ac_wwd;
            default: funcCode = `ac_add;
          endcase
        end
        default: funcCode = `ac_add;
      endcase
    end
  end
endmodule