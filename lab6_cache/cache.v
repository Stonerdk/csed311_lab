`define WORD_SIZE 8'd16
`define OFFSET_SIZE 4'd4
`define IDX_SIZE 4'd4
module cache (
        input          clk, 
        input          reset_n,
        input [15:0]   address1,
        input [15:0]   address2,
        input          cpu_read_m1, 
        input          cpu_read_m2, 
        input          cpu_write_m2,
        input          mem_signal,
        input [63:0]   mem_data1, //from memory, load
        input [63:0]   mem_data2,
        input [15:0]   cpu_data, //from cpu, store
        output reg     hit,
        output         stall,
        output         mem_read_m1,
        output         mem_read_m2,
        output         mem_write_m2,
        output [15:0]  mem_address1,
        output [15:0]  mem_address2,
        output [15:0]  mem_write_data,
        output [15:0]  wb_data1,
        output [15:0]  wb_data2,
        output reg [`WORD_SIZE-1:0]    num_hit,
        output reg [`WORD_SIZE-1:0]    num_miss
    );

    wire [11:0]             address1_tag;
    wire [1:0]              address1_index;
    wire [1:0]              address1_offset;
    wire [11:0]             address2_tag;
    wire [1:0]              address2_index;
    wire [1:0]              address2_offset;
    reg                     set1_valid  [0:`IDX_SIZE - 1];
    reg [11:0]              set1_tag    [0:`IDX_SIZE - 1];
    reg [`WORD_SIZE - 1:0]  set1_data   [0:`IDX_SIZE - 1][0:`OFFSET_SIZE - 1];
    reg                     set1_lru    [0:`IDX_SIZE - 1];
    reg                     set2_valid  [0:`IDX_SIZE - 1];
    reg [11:0]              set2_tag    [0:`IDX_SIZE - 1];
    reg [`WORD_SIZE - 1:0]  set2_data   [0:`IDX_SIZE - 1][0:`OFFSET_SIZE - 1];
    reg                     set2_lru    [0:`IDX_SIZE - 1];
    wire                    addr1_set1_hit, addr1_set2_hit, addr1_hit;
    wire                    addr2_set1_hit, addr2_set2_hit, addr2_hit;
    wire [`WORD_SIZE-1:0]   addr1_data, addr2_data;
    wire [`WORD_SIZE-1:0]   addr1_mem_data, addr2_mem_data;
    integer i;
    integer hit_count;
    integer miss_count;

    assign address1_tag     = address1[15:4];
    assign address1_index   = address1[3:2];
    assign address1_offset  = address1[1:0];
    assign address2_tag     = address2[15:4];
    assign address2_index   = address2[3:2];
    assign address2_offset  = address2[1:0];
    assign mem_address1     = address1;
    assign mem_address2     = address2;
    assign mem_write_data   = cpu_data;
    assign addr1_set1_hit   = set1_valid[address1_index] && set1_tag[address1_index] == address1_tag;
    assign addr1_set2_hit   = set2_valid[address1_index] && set2_tag[address1_index] == address1_tag;
    assign addr1_hit        = (addr1_set1_hit || addr1_set2_hit);
    assign addr2_set1_hit   = set1_valid[address2_index] && set1_tag[address2_index] == address2_tag;
    assign addr2_set2_hit   = set2_valid[address2_index] && set2_tag[address2_index] == address2_tag;
    assign addr2_hit        = (addr2_set1_hit || addr2_set2_hit);
    assign mem_read_m1      = cpu_read_m1 && !addr1_hit;
    assign mem_read_m2      = cpu_read_m2 && !addr2_hit;
    assign mem_write_m2     = cpu_write_m2;
    assign stall            = (mem_read_m1 || mem_read_m2 || mem_write_m2) && !mem_signal;
    assign addr1_data       = addr1_set1_hit ? set1_data[address1_index][address1_offset] : set2_data[address1_index][address1_offset];
    assign addr2_data       = addr2_set1_hit ? set1_data[address2_index][address2_offset] : set2_data[address2_index][address2_offset];
    assign addr1_mem_data   = address1_offset == 0 ? mem_data1[15:0] : address1_offset == 1 ? mem_data1[31:16] : address1_offset == 2 ? mem_data1[47:32] : mem_data1[63:48];
    assign addr2_mem_data   = address2_offset == 0 ? mem_data2[15:0] : address2_offset == 1 ? mem_data2[31:16] : address2_offset == 2 ? mem_data2[47:32] : mem_data2[63:48];
    assign wb_data1         = addr1_hit ? addr1_data : addr1_mem_data;
    assign wb_data2         = addr2_hit ? addr2_data : addr2_mem_data;

    always @(posedge clk) begin
        if (!reset_n) begin
            hit <= 0;
            num_hit <= 0;
            num_miss <= 0;
            for (i = 0; i < `IDX_SIZE; i = i + 1) begin
                set1_valid[i] <= 0;
                set1_tag[i] <= 0;
                set1_data[i][0] = 0;
                set1_data[i][1] <= 0;
                set1_data[i][2] <= 0;
                set1_data[i][3] <= 0;
                set1_lru[i] <= 0;
                set2_valid[i] <= 0;
                set2_tag[i] <= 0;
                set2_data[i][0] <= 0;
                set2_data[i][1] <= 0;
                set2_data[i][2] <= 0;
                set2_data[i][3] <= 0;
                set2_lru[i] <= 0;
            end
        end
        else begin
            if (!stall) begin
                if (cpu_read_m1) begin
                    if (addr1_hit)
                        num_hit <= num_hit + 1;
                    else
                        num_miss <= num_miss + 1;
                end
                if (cpu_read_m2 || cpu_write_m2) begin
                    if (addr2_hit)
                        num_hit <= num_hit + 1;
                    else
                        num_miss <= num_miss + 1;
                end
                if (mem_read_m1) begin
                    if (set1_lru[address1_index] >= set2_lru[address1_index]) begin
                        set1_data[address1_index][0] <= mem_data1[15:0]; 
                        set1_data[address1_index][1] <= mem_data1[31:16]; 
                        set1_data[address1_index][2] <= mem_data1[47:32]; 
                        set1_data[address1_index][3] <= mem_data1[63:48]; 
                        set1_tag[address1_index] <= address1_tag;
                        set1_valid[address1_index] <= 1;
                        set1_lru[address1_index] <= 0;
                        set2_lru[address1_index] <= 1;
                    end
                    else begin
                        set2_data[address1_index][0] <= mem_data1[15:0]; 
                        set2_data[address1_index][1] <= mem_data1[31:16]; 
                        set2_data[address1_index][2] <= mem_data1[47:32]; 
                        set2_data[address1_index][3] <= mem_data1[63:48]; 
                        set2_tag[address1_index] <= address1_tag;
                        set2_valid[address1_index] <= 1;
                        set2_lru[address1_index] <= 0;
                        set1_lru[address1_index] <= 1;
                    end
                end
                else if (mem_read_m2) begin
                    if (set1_lru[address2_index] >= set2_lru[address2_index]) begin
                        set1_data[address2_index][0] <= mem_data2[15:0]; 
                        set1_data[address2_index][1] <= mem_data2[31:16]; 
                        set1_data[address2_index][2] <= mem_data2[47:32]; 
                        set1_data[address2_index][3] <= mem_data2[63:48]; 
                        set1_tag[address2_index] <= address2_tag;
                        set1_valid[address2_index] <= 1;
                        set1_lru[address2_index] <= 0;
                        set2_lru[address2_index] <= 1;
                    end
                    else begin
                        set2_data[address2_index][0] <= mem_data2[15:0]; 
                        set2_data[address2_index][1] <= mem_data2[31:16]; 
                        set2_data[address2_index][2] <= mem_data2[47:32]; 
                        set2_data[address2_index][3] <= mem_data2[63:48]; 
                        set2_tag[address2_index] <= address2_tag;
                        set2_valid[address2_index] <= 1;
                        set2_lru[address2_index] <= 0;
                        set1_lru[address2_index] <= 1;
                    end
                end
                if (mem_write_m2) begin
                    if (addr2_set1_hit)
                        set1_data[address2_index][address2_offset] <= cpu_data;
                    else if (addr2_set2_hit)
                        set2_data[address2_index][address2_offset] <= cpu_data;
                end
            end
        end
    end
endmodule