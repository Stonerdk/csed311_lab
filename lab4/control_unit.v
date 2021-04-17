`include "opcodes.v"
`define ms_if1 5'd0
`define ms_if2 5'd1
`define ms_if3 5'd3
`define ms_if4 5'd2
`define ms_id 5'd4
`define ms_iex1 5'd12
`define ms_iex2 5'd13
`define ms_rex1 5'd8
`define ms_rex2 5'd9
`define ms_bex1 5'd10
`define ms_bex2 5'd11
`define ms_rwb 5'd24
`define ms_iwb 5'd25
`define ms_jmp 5'd26
`define ms_jwb 5'd27
`define ms_wwd 5'd30
`define ms_lwb 5'd29
`define ms_lm1 5'd16
`define ms_lm2 5'd17 
`define ms_lm3 5'd19 
`define ms_lm4 5'd18
`define ms_sm1 5'd20
`define ms_sm2 5'd21
`define ms_sm3 5'd23
`define ms_sm4 5'd22
`define ms_hlt 5'd14
`define ms_rst 5'd31

module control_unit(reset_n, opcode, func_code, clk, pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op);
  input reset_n;
  input [3:0] opcode;
  input [5:0] func_code;
  reg [4:0] state_reg;
  reg [4:0] next_state_reg;
  input clk;

  output pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_src;
  //additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
  output pc_to_reg, halt, wwd, new_inst;
  output [1:0] reg_write, alu_src_A, alu_src_B;
  output alu_op;

  wire isBex, isRex, isIex, isIf, isLm, isSm;

   //TODO: implement control unit

  assign isBex = state_reg == `ms_bex1 || state_reg == `ms_bex2;
  assign isRex = state_reg == `ms_rex1 || state_reg == `ms_rex2;
  assign isIex = state_reg == `ms_iex1 || state_reg == `ms_iex2;
  assign isIf = state_reg == `ms_if1 || state_reg == `ms_if2 || state_reg == `ms_if3 || state_reg == `ms_if4;
  assign isLm = state_reg == `ms_lm1 || state_reg == `ms_lm2 || state_reg == `ms_lm3 || state_reg == `ms_lm4;
  assign isSm = state_reg == `ms_sm1 || state_reg == `ms_sm2 || state_reg == `ms_sm3 || state_reg == `ms_sm4;
  
  assign pc_write_cond = isBex;
  assign pc_write = state_reg == `ms_if4 || state_reg == `ms_jmp || state_reg == `ms_jwb;
  assign i_or_d = isLm || isSm;
  assign mem_read = isIf || isLm;
  assign mem_write = isSm;
  assign mem_to_reg = state_reg == `ms_lwb;
  assign ir_write = state_reg == `ms_if1 || state_reg == `ms_if2 || state_reg == `ms_if3;
  assign pc_src = isBex || state_reg == `ms_jmp || state_reg == `ms_jwb;
  assign pc_to_reg = state_reg == `ms_jwb;
  assign new_inst = state_reg == `ms_if1;
  assign reg_write[1] = state_reg == `ms_rwb || state_reg == `ms_iwb || state_reg == `ms_lwb;
  assign reg_write[0] = state_reg == `ms_jwb || state_reg == `ms_iwb || state_reg == `ms_lwb;
  assign alu_src_A = isRex || isIex || isBex || isSm || isLm;
  assign alu_src_B[1] = state_reg == `ms_id || isIex || isSm || isLm;
  assign alu_src_B[0] = isIf;
  assign alu_op = isRex || isIex || isBex || isLm || isSm;
  assign halt = state_reg == `ms_hlt;
  assign wwd = state_reg == `ms_wwd;

  always @(*) begin  
    case (state_reg)
      `ms_rst: next_state_reg = `ms_if1;
      `ms_if1: next_state_reg = `ms_if2;
      `ms_if2: next_state_reg = `ms_if3;
      `ms_if3: next_state_reg = `ms_if4;
      `ms_if4: next_state_reg = 
        opcode == 4'd9 || opcode == 4'd10 ? `ms_iex1 :
        `ms_id;
      `ms_id: next_state_reg = 
        opcode == 4'd15 ? `ms_rex1 : 
        opcode[3:2] == 2'b00 ? `ms_bex1 : 
        `ms_iex1; 
      `ms_iex1: next_state_reg = `ms_iex2;
      `ms_iex2: next_state_reg = 
        opcode == 9 ? `ms_jmp : 
        opcode == 10 ? `ms_jwb : 
        opcode == 7 ? `ms_lm1 : 
        opcode == 8 ? `ms_sm1 : 
        `ms_iwb;
      `ms_rex1: next_state_reg = `ms_rex2;
      `ms_rex2: next_state_reg = 
        func_code == 25 ? `ms_jmp : 
        func_code == 26 ? `ms_jwb : 
        func_code == 28 ? `ms_wwd :
        func_code == 29 ? `ms_hlt :
        `ms_rwb;
      `ms_bex1: next_state_reg = `ms_bex2;
      `ms_bex2: next_state_reg = `ms_if1;
      `ms_lm1: next_state_reg = `ms_lm2;
      `ms_lm2: next_state_reg = `ms_lm3;
      `ms_lm3: next_state_reg = `ms_lm4;
      `ms_lm4: next_state_reg = `ms_lwb;
      `ms_lwb: next_state_reg = `ms_if1;
      `ms_sm1: next_state_reg = `ms_sm2;
      `ms_sm2: next_state_reg = `ms_sm3;
      `ms_sm3: next_state_reg = `ms_sm4;
      `ms_sm4: next_state_reg = `ms_if1;
      `ms_iwb: next_state_reg = `ms_if1;
      `ms_jmp: next_state_reg = `ms_if1;
      `ms_jwb: next_state_reg = `ms_if1;
      `ms_rwb: next_state_reg = `ms_if1;
      `ms_wwd: next_state_reg = `ms_if1;
      `ms_hlt: next_state_reg = `ms_hlt;
      default: next_state_reg = `ms_hlt;
    endcase
  end

  always @(posedge clk) begin
    if (!reset_n)
      state_reg <= `ms_rst;
    else
      state_reg <= next_state_reg;
  end

endmodule
