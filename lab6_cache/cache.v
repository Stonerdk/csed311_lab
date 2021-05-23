`define WORD_SIZE 4'd16
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
        input [15:0]   mem_data1, //from memory, load
        input [15:0]   mem_data2,
        input [15:0]   cpu_data, //from cpu, store

        output reg     hit,
        output reg     stall,
        output reg     mem_read_m1,
        output reg     mem_read_m2,
        output reg     mem_write_m2,
        output [15:0]  mem_address1,
        output [15:0]  mem_address2,
        output [15:0]  mem_write_data,
        output reg [15:0]   wb_data1,
        output reg [15:0]   wb_data2
    );

    wire [11:0]             address1_tag;
    wire [1:0]              address1_index;
    wire [1:0]              address1_offset;
    wire [11:0]             address2_tag;
    wire [1:0]              address2_index;
    wire [1:0]              address2_offset;
    reg                     set1_valid  [0:`IDX_SIZE - 1];
    reg [1:0]               set1_tag    [0:`IDX_SIZE - 1];
    reg [`WORD_SIZE - 1:0]  set1_data   [0:`IDX_SIZE - 1][0:`OFFSET_SIZE - 1];
    reg                     set1_lru    [0:`IDX_SIZE - 1];
    reg                     set2_valid  [0:`IDX_SIZE - 1];
    reg [1:0]               set2_tag    [0:`IDX_SIZE - 1];
    reg [`WORD_SIZE - 1:0]  set2_data   [0:`IDX_SIZE - 1][0:`OFFSET_SIZE - 1];
    reg                     set2_lru    [0:`IDX_SIZE - 1];
    reg                     set1_hit, set2_hit;
    integer i;
    assign address1_tag = address1[15:4];
    assign address1_index = address1[3:2];
    assign address1_offset = address1[1:0];
    assign address2_tag = address2[15:4];
    assign address2_index = address2[3:2];
    assign address2_offset = address2[1:0];

    assign mem_address1 = address1;
    assign mem_address2 = address2;
    assign mem_write_data = cpu_data;

    always @(*) begin
        stall = mem_read_m1 || mem_read_m2 || mem_write_m2;
        if (!stall) begin
            if (cpu_read_m1) begin
                set1_hit = set1_valid[address1_index] && set1_tag[address1_index] == address1_tag;
                set2_hit = set2_valid[address1_index] && set2_tag[address1_index] == address1_tag;
                hit = set1_hit || set2_hit;
                if (!hit)
                    mem_read_m1 = 1;
            end
            if (cpu_read_m2) begin
                set1_hit = set1_valid[address2_index] && set1_tag[address2_index] == address2_tag;
                set2_hit = set2_valid[address2_index] && set2_tag[address2_index] == address2_tag;
                hit = set1_hit || set2_hit;
                if (!hit)
                    mem_read_m2 = 1;
            end

            if (cpu_write_m2) begin
                set1_hit = set1_valid[address2_index] && set1_tag[address2_index] == address2_tag;
                set2_hit = set2_valid[address2_index] && set2_tag[address2_index] == address2_tag;
                hit = set1_hit || set2_hit;
                mem_write_m2 = 1;
            end
        end
        if (mem_signal) begin
            if (mem_read_m1) begin
                wb_data1 = mem_data1[address1_offset];
                if (set1_lru[address1_index] >= set2_lru[address1_index]) begin
                    set1_data[address1_index] = mem_data1[address1_offset]; 
                    set1_tag[address1_index] = address1_tag;
                    set1_valid[address1_index] = 1;
                    set1_lru[address1_index] = 0;
                    set2_lru[address1_index] = 1;
                end
                else begin
                    set2_data[address1_index] = mem_data1[address1_offset];
                    set2_tag[address1_index] = address1_tag;
                    set2_valid[address1_index] = 1;
                    set2_lru[address1_index] = 0;
                    set1_lru[address1_index] = 1;
                end
                mem_read_m1 = 0;
            end
            else if (mem_read_m2) begin
                wb_data2 = mem_data2[address2_offset];
                if (set1_lru[address2_index] >= set2_lru[address2_index]) begin
                    set1_data[address2_index] = mem_data2[address2_offset]; 
                    set1_tag[address2_index] = address_tag;
                    set1_valid[address2_index] = 1;
                    set1_lru[address2_index] = 0;
                    set2_lru[address2_index] = 1;
                end
                else begin
                    set2_data[address2_index] = mem_data2[address2_offset];
                    set2_tag[address2_index] = address2_tag;
                    set2_valid[address2_index] = 1;
                    set2_lru[address2_index] = 0;
                    set1_lru[address2_index] = 1;
                end
                mem_read_m2 = 0;
            end
            else if (mem_write_m2)
                mem_write_m2 = 0;
        end
    end
    always @(negedge clk) begin
        if (!reset_n) begin
            hit <= 0;
            stall <= 0;
            mem_read_m1 <= 0;
            mem_read_m2 <= 0;
            wb_data1 <= 0;
            wb_data2 <= 0;
            set1_hit <= 0;
            set2_hit <= 0;
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
            if (hit) begin
                if (cpu_read_m1)
                    wb_data1 <= set1_hit ? set1_data[address1_index][address1_offset] : set2_data[address1_index][address1_offset];
                else if (cpu_read_m2)
                    wb_data2 <= set1_hit ? set1_data[address2_index][address2_offset] : set2_data[address2_index][address2_offset];
                else if (cpu_write_m2) begin
                    if (set1_hit)
                        set1_data[address2_index][address2_offset] <= cpu_data;
                    else if (set2_hit)
                        set2_data[address2_index][address2_offset] <= cpu_data;
                end 
            end
        end
    end
endmodule