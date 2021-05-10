`include "opcodes.v" 

module branch_predictor(clk, reset_n, PC, instruction, ifid_branch, bcond, next_PC, eval_bcond);

	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] PC;
	input [`WORD_SIZE-1:0] instruction;
	input ifid_branch;
	input bcond; // not taken

	output [`WORD_SIZE-1:0] next_PC;
	output eval_bcond;

	reg[1:0] saturation;
	wire [`WORD_SIZE-1:0] imm;

	// assign next_PC = PC + 1;

	assign imm[7:0] = instruction[7:0];
	assign imm[15:8] = imm[7] ? 8'hff : 8'h00;
	assign eval_bcond = saturation[1];
	assign next_PC = saturation[1] ? PC + imm + 1 : PC + 1;

	always @(posedge clk) begin
		if (!reset_n) begin
			saturation <= 2'b10;
		end	

		if (ifid_branch) begin
			if (bcond)
				saturation <= saturation != 2'b00 ? saturation - 1 : 0;
			else
				saturation <= saturation != 2'b11 ? saturation + 1 : 0;
		end
	end 
endmodule

module branch_predictor_btb(clk, reset_n, PC, instruction, ifid_branch, bcond, next_PC, eval_bcond);

	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] PC;
	input [`WORD_SIZE-1:0] instruction;
	input ifid_branch;
	input bcond; // not taken

	output [`WORD_SIZE-1:0] next_PC;
	output eval_bcond;

	reg[1:0] saturation;

	reg[1 : 0] index1;
	reg[1 : 0] index2;
	reg[1 : 0] index3;
	reg[1 : 0] index4; //index BNE BEQ BGZ BLZ
	
	reg[11:0] tag1;
	reg[11:0] tag2;
	reg[11:0] tag3;
	reg[11:0] tag4;	 //tag BNE BEQ BGZ BLZ

	reg [`WORD_SIZE-1:0] predict_pc1;
	reg [`WORD_SIZE-1:0] predict_pc2;
	reg [`WORD_SIZE-1:0] predict_pc3;
	reg [`WORD_SIZE-1:0] predict_pc4;  //predict_pc BNE BEQ BGZ BLZ
	
	wire [11:0] tag;
	wire [`WORD_SIZE-1:0] imm;  //현재 isntruction의 정보

	initial begin
		assign index1 = 2`b00;
		assign index2 = 2`b01;
		assign index3 = 2`b10;
		assign index4 = 2`b11;
	end

	// assign next_PC = PC + 1;

	assign tag = instruction[11:0];
	assign current_index = instruction[13:12];

	assign imm[7:0] = instruction[7:0];
	assign imm[15:8] = imm[7] ? 8'hff : 8'h00;
	assign eval_bcond = saturation[1];


	//assign next_PC = saturation[1] ? PC + imm + 1 : PC + 1;
	if(saturation[1] == 1) begin
		if(index1 == current_index) begin
			if(tag1 == tag) begin
				if(predict_pc1 != 0) begin
					assign next_pc = predict_pc1
				end
			end
		end
		else if(index2 == current_index) begin
			if(tag2 == tag) begin
				if(predict_pc2 != 0) begin
					assign next_pc = predict_pc2
				end
			end
			
		end
		else if(index3 == current_index) begin
			if(tag3 == tag) begin
				if(predict_pc3 != 0) begin
					assign next_pc = predict_pc3
				end
			end
		end
		else if(index4 == current_index) begin
			if(tag4 == tag) begin
				if(predict_pc4 != 0) begin
					assign next_pc = predict_pc4
				end
			end
		end
	end
	else begin
		assign next_pc = PC + 1;
	end


	always @(posedge clk) begin
		if (!reset_n) begin
			saturation <= 2'b10;
			predict_pc1 <= 0;
			predict_pc2 <= 0;
			predict_pc3 <= 0;
			predict_pc4 <= 0;
		end	

		// predictpc 에 머넞 hardcoding되어 있어야 해

		// 2 bit predictor update
		if (ifid_branch) begin
			if (bcond) // 실제로 브랜치가 taken일 때
			    // table update
				saturation <= saturation != 2'b00 ? saturation - 1 : 0;
			else  // 브랜치가 not taken 일때.
				// table update
				if(saturation[1] == 1) begin
					
				end
				saturation <= saturation != 2'b11 ? saturation + 1 : 0;
		end
	end 
endmodule