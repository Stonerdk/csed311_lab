`define WORD_SIZE 16

module dma(clk, begin_dma, length, target_address, bg, mem_signal, memory_address,br, mtoe, index, dma_end);
input clk;
input begin_dma;        // cpu가 보내는 interrupt
input [`WORD_SIZE-1 : 0] length;  // 12
input [`WORD_SIZE-1 : 0] target_address; // 16'b20

input bg;
input mem_signal;

output  [`WORD_SIZE-1 : 0] memory_address;
output  br;     
wire br;
reg br_;
output  mtoe; //memory to external device signal
wire mtoe;
reg mtoe_;
output [5 :0] index;
wire [5:0] index;
reg [5:0]index_;

output dma_end;
wire dma_end;
reg dma_end_;

reg [5 : 0] prepare_dma;
// index 4개식
reg [5:0] i;

initial begin
    i = 0;
    index_ = 0;
    br_ = 0;
    mtoe_ = 0;
    dma_end_ = 0;
    prepare_dma = 0;
end
/////////////////

assign dma_end = dma_end_;
assign mtoe = mtoe_;
assign br = br_;
assign index = index_;
assign memory_address = target_address + index_;

always@(posedge clk) begin
    if(begin_dma)begin
        br_ <= 1;    // bus request
    end
    if(dma_end_) begin
        dma_end_ <= 0;
    end

    if(bg == 1) begin
        prepare_dma <= prepare_dma +1 ;
        if(prepare_dma == 10) begin
            if(index_ == 0)begin
                mtoe_ <= 1;
                index_ <= i;
                i <= i + 4;
            end
        end
        else if ( prepare_dma > 10 )begin
            if(mem_signal) begin
                if( index_ < length) begin
                    mtoe_ <= 1;
                    index_ <= i;
                    i <= i + 4;
                end
                else begin
                    i <= 0;
                    br_ <= 0;
                    mtoe_ <= 0;
                    dma_end_ <= 1;
                end
            end
        end
    end
end



endmodule