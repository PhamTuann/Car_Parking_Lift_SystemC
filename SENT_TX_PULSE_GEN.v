module sent_tx_pulse_gen(
	//clk and reset_n_tx
	input clk_tx,
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
	reg sig_ticks;
	reg [10:0] count_ticks_i;
	reg [15:0] count;
	reg [3:0] count_zero_idle;

	always @(posedge clk_tx or negedge reset_n_tx) begin
		if(!reset_n_tx) begin
			count <= 0;
			sig_ticks <= 0;
			count_ticks_i <= 0;
			count_zero_idle <= 0;
			pulse_done_o <= 0;
			data_pulse_o <= 1;
		end
		else begin
			sig_ticks <= ticks_i;
			if(pulse_done_o) pulse_done_o <= 0;
			if(sync_i) begin
				if((ticks_i == 1) && (sig_ticks==0)) begin
    					count <= count+1;
					if(count > 5) begin
					data_pulse_o <= 1;
					if(count == 56) begin
						data_pulse_o <= 0;
						pulse_done_o <= 1;
						count <= 1;
						count_ticks_i <= count_ticks_i + 56;
					end
				end 
				else begin
					data_pulse_o <= 0;
				end
  				end
				count_zero_idle <= 0;
				
			end
			if(pulse_i) begin
				if((ticks_i == 1) && (sig_ticks==0)) begin
    					count <= count+1;
					if(count > 5) begin
					data_pulse_o <= 1;
					if(count == 12 + data_nibble_i) begin
						data_pulse_o <= 0;
						pulse_done_o <= 1;
						count <= 1;
						count_ticks_i <= count_ticks_i + 12 + data_nibble_i;
					end
				end 
				else begin
					data_pulse_o <= 0;
				end
  				end
				count_zero_idle <= 0;
				
			end
			if(pause_i) begin
				if((ticks_i == 1) && (sig_ticks==0)) begin
    					count <= count+1;
					if(count > 5) begin
					data_pulse_o <= 1;
					if(count == 280 - count_ticks_i) begin
						data_pulse_o <= 0;
						pulse_done_o <= 1;
						count <= 1;
						count_ticks_i <= 0;
					end
				end 
				else begin
					data_pulse_o <= 0;
				end
  				end
				count_zero_idle <= 0;
				
			end
			if(idle_i) begin
				count <= 0;
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
endmodule
