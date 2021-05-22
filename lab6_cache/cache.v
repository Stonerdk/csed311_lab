`define WORD_SIZE 16
`define OFFSET_SIZE 4
`define IDX_SIZE 4
module cache ()

    input[15:0] address;

    output hit;

    wire [11:0] address_tag;
    wire [1:0] address_index;
    wire [1:0] address_offset;

    reg set1_valid [0:IDX_SIZE - 1];
    reg [1:0] set1_tag [0:IDX_SIZE - 1];
    reg [WORD_SIZE - 1:0] set1_data [0:IDX_SIZE - 1][0:OFFSET_SIZE - 1];

    reg set2_valid [0:IDX_SIZE - 1];
    reg [1:0] set2_tag [0:IDX_SIZE - 1];
    reg [WORD_SIZE - 1:0] set2_data [0:IDX_SIZE - 1][0:OFFSET_SIZE - 1];

    wire set1_hit, set2_hit;

    assign address_tag = address[15:4];
    assign address_index = address[3:2];
    assign address_offset = address[1:0];

    assign set1_hit = set1_valid[address_index] && set1_tag[address_index] == address_tag;
    assign set2_hit = set2_valid[address_index] && set2_tag[address_index] == address_tag;
    assign hit = set1_hit || set2_hit;

    

endmodule