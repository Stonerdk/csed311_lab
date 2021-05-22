`include "opcodes.v" 

module branch_predictor(clk, reset_n, PC, is_flush, taken, datahazard, is_branch, is_jump, actual_next_PC, actual_PC, next_PC);

	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] PC;
	input is_flush;
	input taken;
	input datahazard;
	input is_branch, is_jump;
	input [`WORD_SIZE-1:0] actual_next_PC; //computed actual next PC from branch resolve stage
	input [`WORD_SIZE-1:0] actual_PC; // PC from branch resolve stage

	output [`WORD_SIZE-1:0] next_PC;

	wire [7:0] actual_pc_idx;
	wire [7:0] actual_pc_tag;
	wire [7:0] pc_idx;
	wire [7:0] pc_tag;
	wire cache_hit;

	reg [7:0] TAG [0:255];
	reg [`WORD_SIZE-1:0] TARGET [0:255];
	reg [1:0] SATURATION;
	reg [`WORD_SIZE-1:0] i;

	assign actual_pc_idx = actual_PC[7:0];
	assign actual_pc_tag = actual_PC[15:8];
	assign pc_idx = PC[7:0];
	assign pc_tag = PC[15:8];
	
	assign cache_hit = pc_tag == TAG[pc_idx];
	assign next_PC = is_flush ? actual_next_PC : ((cache_hit && (SATURATION[1] || is_jump)) ? TARGET[pc_idx] : PC + 1);
	//assign next_PC = is_flush ? actual_next_PC : cache_hit ? TARGET[pc_idx] : PC + 1; // always taken
	//assign next_PC = is_flush ? actual_next_PC : PC + 1; //always not taken
	always @(posedge clk) begin
		if (!reset_n) begin
			for (i = 1; i < 256; i = i + 1) begin
				TAG[i] <= 0;
				TARGET[i][15:8] <= 0;
				TARGET[i][7:0] <= i + 1;
			end
			TAG[0] <= 0;
			TARGET[0] <= 35;
			SATURATION <= 2;
		end

		else begin
			
			if ((is_branch || is_jump) && !datahazard) begin
				if (is_branch) begin
					if (taken)
						SATURATION <= SATURATION == 3 ? 3 : SATURATION + 1;
					else
						SATURATION <= SATURATION == 0 ? 0 : SATURATION - 1;
				end
				TAG[actual_pc_idx] <= actual_pc_tag;
				TARGET[actual_pc_idx] <= actual_next_PC;
			end	
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