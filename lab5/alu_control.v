`include "opcodes.v"

// control_unit에서 생성된 aluop값을 이용해 바로
// alu를 control 하는 alu_control 값을 생성.

module alu_control(funct, opcode, ALUOp, clk, funcCode, branchType);
  input ALUOp;
  input clk;
  input [5:0] funct;
  input [3:0] opcode;

  output reg [3:0] funcCode;
  output reg [2:0] branchType;

   //TODO: implement ALU control unit

  always @(*) begin
    if (ALUOp == 0) begin
      funcCode = `ac_add;
    end // pc에 대한 add operation 이 ID 단계로 옮겨 가서 필요없음.
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
            25: funcCode = `ac_jr;
            26: funcCode = `ac_jr;
            28: funcCode = `ac_wwd;
            default: funcCode = `ac_add;
          endcase
        end
        default: funcCode = `ac_add;
                brach_type = `none;
      endcase
    end
  end
endmodule