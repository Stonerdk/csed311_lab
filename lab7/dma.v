`define WORD_SIZE 16

module dma(clk, begin_dma, length, target_address, bg, memory_address,br, mtoe, index);
input clk;
input begin_dma;        // cpu가 보내는 interrupt
input [`WORD_SIZE-1 : 0] length;  // 12
input [`WORD_SIZE-1 : 0] target_address; // 16'b20

input bg;

output reg [`WORD_SIZE-1 : 0] memory_address;
output reg br;
output reg mtoe; //memory to external device signal
output [5 :0] index;

// index 4개식
integer i;
reg index_;

initial begin
    assign i = 0;
    assign index_ = -1;
    assign br = 0;
    assign mtoe = 0;
    assign memory_address = 0;
end
/////////////////


assign index = index_;
assign memory_address = target_address + index_;

always@(posedge clk) begin
    if(begin_dma)begin
        br <= 1;    // bus request
    end

    if( bg == 1 ) begin
        if( index_ < length) begin
            index_ <= i;
            mtoe <= 1;
            i <= i + 1;
        end
        else begin
            i <= 0;
            br <= 0;
            mtoe <= 0;
        end
    end

end



endmodule