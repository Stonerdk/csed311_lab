
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;




	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		input_total = 0;
		output_total = 0;
		return_total = 0;
		current_total_nxt = 0;

		if(o_return_coin[2] == 1 ) begin
			return_total = coin_value[2];
		end
		else if(o_return_coin[1] == 1 ) begin
			return_total = coin_value[1];
		end
		else if(o_return_coin[0] == 1 ) begin
			return_total = coin_value[0];
		end
		else begin
			return_total = 0;
		end

		if (i_input_coin[0] == 1 ) begin
			input_total = coin_value[0];
		end
		else if (i_input_coin[1] == 1 ) begin
			input_total = coin_value[1];
		end
		else if (i_input_coin[2] == 1 ) begin
			input_total = coin_value[2];
		end
		else input_total = 0;

		if(i_select_item[0] == 1 && current_total >= item_price[0]) begin
			output_total = item_price[0];
		end
		else if(i_select_item[1] == 1 && current_total >= item_price[1]) begin
			output_total = item_price[1];
		end
		else if(i_select_item[2] == 1 && current_total >= item_price[2]) begin
			output_total = item_price[2];
		end
		else if(i_select_item[3] == 1 && current_total >= item_price[3]) begin
			output_total = item_price[3];
		end
		else begin
			output_total = 0;
		end

		current_total_nxt = input_total + current_total - output_total - return_total;
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item
		o_available_item = 0; o_output_item = 0;

		if(current_total >= item_price[0]) o_available_item[0] = 1;
		if(current_total >= item_price[1]) o_available_item[1] = 1;
		if(current_total >= item_price[2]) o_available_item[2] = 1;
		if(current_total >= item_price[3]) o_available_item[3] = 1;

		o_output_item = i_select_item & o_available_item;
	end
 
	


endmodule 