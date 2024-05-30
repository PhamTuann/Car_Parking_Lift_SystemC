module sent_tx_data_reg(
	//clk_tx and reset_n_tx
	input clk_tx,
	input reset_n_tx,

	//signals to control block
	input [2:0] load_bit_i,
	output reg [15:0] data_f1_o,
	output reg [11:0] data_f2_o,
	output reg done_pre_data_o,	

	//signals to fifo
	input [11:0] data_fast_i,
	input fifo_tx_empty_i,
	output reg read_enable_tx_o
	);

	reg [4:0] count_enable;
	reg [2:0] count_store;

	reg [11:0] saved_data1;
	reg [11:0] saved_data2;


	//CONTROL
	always @(posedge clk_tx or negedge reset_n_tx) begin
		if(!reset_n_tx) begin
			count_enable <= 0;
			read_enable_tx_o <= 0;
			saved_data1 <= 0;
			saved_data2 <= 0;
			done_pre_data_o <= 0;
			count_store <= 0;
			
		end
		else begin
			if(load_bit_i == 3'b001 || load_bit_i == 3'b110 || load_bit_i == 3'b111) begin
				if(!fifo_tx_empty_i) begin
				if(count_enable == 6) begin
					read_enable_tx_o <= 1;
					count_enable <= 0;
					if(!count_store) begin
						saved_data1 <= data_fast_i; 
						count_store <= 1; 
					end else begin 
						saved_data2 <= data_fast_i; 
						count_store <= 0; 
						done_pre_data_o <= 1; 
					end
				end
				else begin count_enable <= count_enable + 1; end
				end
				else begin
					saved_data1 <= 0;
					saved_data2 <= 0;
					done_pre_data_o <= 1;
				end
			end
			else if(load_bit_i == 3'b010 || load_bit_i == 3'b011 || load_bit_i == 3'b100 || load_bit_i == 3'b101)begin
				if(!fifo_tx_empty_i) begin	
				if(count_enable == 6) begin
					read_enable_tx_o <= 1;
					count_enable <= 0;
					saved_data1 <= data_fast_i; 
					done_pre_data_o <= 1; 
				end
				else begin count_enable <= count_enable + 1; end
				end
				else begin
					saved_data1 <= 0;
					done_pre_data_o <= 1;
				end
			end
			else begin 
				read_enable_tx_o <= 0;
				count_enable <= 0;
			end
			
			if(done_pre_data_o) done_pre_data_o <= 0;
			if(read_enable_tx_o) read_enable_tx_o <= 0;
		end
	end

	//DATA
	always @(posedge clk_tx or negedge reset_n_tx) begin
		if(!reset_n_tx) begin
			data_f1_o <= 0;
			data_f2_o <= 0;
		end
		else begin
			//data fast channel 1
			if(done_pre_data_o) begin 
				case(load_bit_i)
					3'b001: begin data_f1_o <= saved_data1; data_f2_o <= saved_data2; end
					3'b010: begin data_f1_o <= saved_data1; end
					3'b011: begin data_f1_o <= saved_data1; end
					3'b100: begin data_f1_o <= saved_data1; end
					3'b101: begin data_f1_o <= saved_data1; end
					3'b110: begin data_f1_o <= {saved_data1, saved_data2[11:10]}; data_f2_o <= saved_data2[9:0]; end
					3'b111: begin data_f1_o <= {saved_data1, saved_data2[11:8]}; data_f2_o <= saved_data2[7:0]; end
				endcase
			end
		end
	end
endmodule
