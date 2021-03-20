`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,item_price,coin_value,reset_n,i_trigger_return,current_total,wait_time,o_return_coin);
	input clk;
	input reset_n;
	input i_trigger_return;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];
	input [`kTotalBits-1:0] current_total;
	output reg [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time; 
	// initiate values
	initial begin
		wait_time = 0;
		o_return_coin = 0;
	end


	// update coin return time
	always @(i_select_item,i_input_coin) begin
		if(i_input_coin != 0) begin
			wait_time = 100; 
			o_return_coin = 0;
		end

		if(i_select_item != 0) begin
			if (i_select_item[0] == 1 && current_total >= item_price[0]) begin
				wait_time = 100;
			end
			else if (i_select_item[1] == 1 && current_total >= item_price[1]) begin
				wait_time = 100;
			end
			else if (i_select_item[2] == 1 && current_total >= item_price[2]) begin
				wait_time = 100;
			end
			else if (i_select_item[3] == 1 && current_total >= item_price[3]) begin
				wait_time = 100;
			end
			else begin
				wait_time = wait_time;
			end			
		end		
	end

	always @(*) begin //�ð��� �� �Ǹ� ������ ��ȯ�Ѵ�.
		// TODO: o_return_coin
		o_return_coin = 0;

		if(wait_time == 0) begin
			if(current_total >= coin_value[2]) o_return_coin[2] = 1;
			else if(current_total >= coin_value[1]) o_return_coin[1] = 1;
			else if(current_total >= coin_value[0]) o_return_coin[0] = 1;
			else o_return_coin = 0;
		end
	end



	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
			wait_time <= 0;
		end
		else begin
		// TODO: update all states.
		if(wait_time > 0) wait_time <= wait_time -1;
		end
	end
endmodule 