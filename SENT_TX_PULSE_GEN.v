module sent_tx_pulse_gen(
	//clk and reset_n_tx
	input ticks_i,
	input reset_n_tx,

	//signals to control
	input [3:0] data_nibble_i,
	input pulse_i,
	input sync_i,
	input pause_i,
	input idle_i,
	output reg pulse_done_o,

	//output sent tx
	output reg data_pulse_o
	);

	reg [3:0] count_zero;
	reg [7:0] count_data;	
	reg [8:0] count_ticks_i;

	reg [3:0] count_zero_idle;

	always @(posedge ticks_i or negedge reset_n_tx) begin
		if(!reset_n_tx) begin
			data_pulse_o <= 1;
			pulse_done_o <= 0;
			count_zero <= 0;
			count_data <= 0;
			count_ticks_i <= 0;
			count_zero_idle <= 0;
		end
		else begin
			if(sync_i) begin
				count_zero_idle <= 0;
				if(count_zero == 5) begin
					data_pulse_o <= 1;
					if(count_data == 51) begin
						data_pulse_o <= 0;
						count_data <= 0;
						count_zero <= 0;
						pulse_done_o <= 1;
						count_ticks_i <= count_ticks_i + 56;
					end
					else begin
						count_data <= count_data + 1;
					end
				end 
				else begin
					count_zero <= count_zero + 1;
					data_pulse_o <= 0;
				end
			end

			if(pulse_i) begin
				if(count_zero == 5) begin
					data_pulse_o <= 1;
					if(count_data == 7 + data_nibble_i) begin
						data_pulse_o <= 0;
						count_data <= 0;
						count_zero <= 0;
						pulse_done_o <= 1;
						count_ticks_i <= count_ticks_i + 12 + data_nibble_i;
					end
					else begin
						count_data <= count_data + 1;
					end
				end 
				else begin
					count_zero <= count_zero + 1;
					data_pulse_o <= 0;
				end
			end
			
			if(pause_i) begin
				if(count_zero == 5) begin
					data_pulse_o <= 1;
					if(count_data == 250 - count_ticks_i) begin
						data_pulse_o <= 0;
						count_data <= 0;
						count_zero <= 0;
						pulse_done_o <= 1;
						count_ticks_i <= 0;
					end
					else begin
						count_data <= count_data + 1;
					end
				end 
				else begin
					count_zero <= count_zero + 1;
					data_pulse_o <= 0;
				end
			end
			if(idle_i) begin
				if(count_zero_idle == 5) begin
					data_pulse_o <= 1;
				end 
				else begin
					count_zero_idle <= count_zero_idle + 1;
					data_pulse_o <= 0;
				end
			end
		end
	end	
	
	always @(posedge ticks_i or negedge reset_n_tx) begin
		if(!reset_n_tx) begin

		end
		else begin
			if(pulse_done_o) pulse_done_o <= 0;
		end
	end
endmodule
