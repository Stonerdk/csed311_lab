`include "opcodes.v"
// ID 단계에서 바로 다음 pc를 예측.
//BNE BEQ BGZ BLZ JMP JAL 
//JPR JRL 은 레지스터의 값을 가져와야 하므로 그대로 EX단계에서 PC 계산
// 일단은 default 로 A + B 값을 next_pc로 주지만,
// 이후 mux에서 이를 검사 하여 다음 pc를 결정한다.
//ID에서 레지스터의 값을 직접 비교한 후 나온 condition_bit를 input으로.

module alu_pc(A,B,next_pc);

input [`WORD_SIZE-1:0] A; //현재 PC
input [`WORD_SIZE-1:0] B; //offset

output [`WORD_SIZE-1:0] next_pc; // 주어진 현재 pc 와 offset을 이용해 다음 pc를 계산하여 output으로 내보내줌.

initial begin
    assign next_pc = 0;
end

while(*) begin
    if(aluop == 0) begin
        next_pc = A + B;
    end
end
endmodule