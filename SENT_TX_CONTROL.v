module sent_tx_control(
	//clk_tx and reset_n_tx
	input clk_tx,
	input reset_n_tx,
	input [1:0] done,
	//normal input
	input channel_format_i, //0: serial, 1: enhanced
	input optional_pause_i,
	input config_bit_i,
	input enable_i,
	input [7:0] id_i,
	input [15:0] data_bit_field_i,
	
	//signals to crc block
	input [5:0] crc_gen_i,
	output reg [2:0] enable_crc_gen_o,
	output reg [23:0] data_gen_crc_o,

	//signals to pulse_o gen block
	input pulse_done_i,
	output reg [3:0] data_nibble_o,
	output reg pulse_o,
	output reg sync_o,
	output reg pause_o,
	output reg idle_o,
	
	//signals to data reg block
	input [15:0] data_f1_i,
	input [11:0] data_f2_i,
	input done_pre_data_i,
	output reg [2:0] load_bit_o
	);

	//frame format of fast channels
	localparam TWO_FAST_CHANNELS_12_12 = 1;
	localparam ONE_FAST_CHANNELS_12 = 2;
	localparam HIGH_SPEED_ONE_FAST_CHANNEL_12 = 3;
	localparam SECURE_SENSOR = 4;
	localparam SINGLE_SENSOR_12_0 = 5;
	localparam TWO_FAST_CHANNELS_14_10 = 6;
	localparam TWO_FAST_CHANNELS_16_8 = 7;

	//state FSMs
	localparam IDLE = 0;
	localparam SYNC = 1;
	localparam STATUS = 2;
	localparam DATA = 3;
	localparam CRC = 4;
	localparam PAUSE = 5;

	reg [2:0] frame_format;
	reg [2:0] state;
	reg [5:0] count_frame;
	reg [2:0] count_nibble;
	
	reg [2:0] count_load;

	reg [15:0] saved_short_data;
	reg [17:0] saved_enhanced_bit3;
	reg [17:0] saved_enhanced_bit2;

	reg [7:0] bit_counter;
	
	reg [23:0] data_gen_crc;
	reg [2:0] saved_frame_format;
	reg [23:0] saved_data_fast;

	//PREPARE DATA CHANNEL TO GEN CRC
	always @(*) begin
		if(!channel_format_i) begin data_gen_crc = {id_i[3:0], data_bit_field_i[7:0]}; end
		else if(channel_format_i && !config_bit_i) begin 
			data_gen_crc = {data_bit_field_i[11], 1'b0, data_bit_field_i[10], config_bit_i
					,data_bit_field_i[9], id_i[7], data_bit_field_i[8], id_i[6]
					,data_bit_field_i[7], id_i[5] , data_bit_field_i[6], id_i[4]
					,data_bit_field_i[5], 1'b0, data_bit_field_i[4], id_i[3]
					,data_bit_field_i[3], id_i[2], data_bit_field_i[2], id_i[1]
					,data_bit_field_i[1], id_i[0], data_bit_field_i[0], 1'b0 };
		end
		else begin 
			data_gen_crc = {data_bit_field_i[11], 1'b0, data_bit_field_i[10], config_bit_i
					,data_bit_field_i[9], id_i[3], data_bit_field_i[8], id_i[2]
					,data_bit_field_i[7], id_i[1], data_bit_field_i[6], id_i[0]
					,data_bit_field_i[5], 1'b0, data_bit_field_i[4], data_bit_field_i[15]
					,data_bit_field_i[3], data_bit_field_i[14], data_bit_field_i[2], data_bit_field_i[13]
					,data_bit_field_i[1], data_bit_field_i[12], data_bit_field_i[0], data_bit_field_i[11] };	
		end
	end

	//DEFINE FRAME FORMAT	
	always @(*) begin
		case(data_bit_field_i)
			16'h001: frame_format = TWO_FAST_CHANNELS_12_12;
			16'h002: frame_format = ONE_FAST_CHANNELS_12;
			16'h003: frame_format = HIGH_SPEED_ONE_FAST_CHANNEL_12;
			16'h004: frame_format = SECURE_SENSOR;
			16'h005: frame_format = SINGLE_SENSOR_12_0;
			16'h006: frame_format = TWO_FAST_CHANNELS_14_10;
			16'h007: frame_format = TWO_FAST_CHANNELS_16_8;
			default: frame_format = TWO_FAST_CHANNELS_12_12;
		endcase
	end

	//PREPARE DATA FAST
	always @(*) begin
		case(saved_frame_format)
			TWO_FAST_CHANNELS_12_12: 	begin saved_data_fast = {data_f1_i[11:0], data_f2_i[3:0], data_f2_i[7:4], data_f2_i[11:8]}; 					end
			ONE_FAST_CHANNELS_12: 		begin saved_data_fast = {data_f1_i[11:0]}; 											end
			HIGH_SPEED_ONE_FAST_CHANNEL_12: begin saved_data_fast = {1'b0,data_f1_i[11:9],1'b0,data_f1_i[8:6],1'b0,data_f1_i[5:3],1'b0,data_f1_i[2:0]}; 			end
			SECURE_SENSOR:			begin saved_data_fast = {data_f1_i[11:0], bit_counter[7:0], !data_f1_i[11], !data_f1_i[10], !data_f1_i[9], !data_f1_i[8]}; 	end
			SINGLE_SENSOR_12_0:		begin saved_data_fast = {data_f1_i[11:0],12'b0}; 										end
			TWO_FAST_CHANNELS_14_10:	begin saved_data_fast = {data_f1_i[13:0],data_f2_i[1:0],data_f2_i[5:2],data_f2_i[9:6]}; 					end
			TWO_FAST_CHANNELS_16_8:		begin saved_data_fast = {data_f1_i,data_f2_i[3:0],data_f2_i[7:4]}; 								end
			default: 			begin saved_data_fast = 24'h000000; end
		endcase
	end

	//FSM
	always @(posedge clk_tx or negedge reset_n_tx) begin
		if(!reset_n_tx) begin
			data_nibble_o <= 0;
			state <= IDLE;
			sync_o <= 0;
			pause_o <= 0;
			pulse_o <= 0;
			idle_o <= 0;
			count_frame <= 0;
			saved_short_data <= 0;
			saved_enhanced_bit3 <= 0;
			saved_enhanced_bit2 <= 0;

			enable_crc_gen_o <= 0;
			data_gen_crc_o <= 24'h000000;
			saved_frame_format <= 0;
			load_bit_o <= 0;
		
			bit_counter <= 0;
			count_load <= 0;
		
		end
		else begin
			if(enable_crc_gen_o != 0) begin enable_crc_gen_o <= 0; end

			
				
				if(done == 2'b10) begin
				if(!config_bit_i) begin
				saved_enhanced_bit3 <= {7'b1111110, config_bit_i, id_i[7:4],1'b0,id_i[3:0], 1'b0};
				saved_enhanced_bit2 <= {crc_gen_i, data_bit_field_i[11:0]};
					end
					else begin
				saved_enhanced_bit3 <= {7'b1111110, config_bit_i, id_i[3:0], 1'b0, data_bit_field_i[15:12], 1'b0};
				saved_enhanced_bit2 <= {crc_gen_i, data_bit_field_i[11:0]};
				end
			
		
			end

			case(state) 
				IDLE: begin
					
					//CHANGE STATE					
					if(enable_i) begin
						state <= SYNC;
						count_frame <= 0;
						idle_o <= 0;

						//PREPARE DATA CHANNEL TO GEN CRC
						data_gen_crc_o <= data_gen_crc;						
						saved_frame_format <= frame_format;
						if(!channel_format_i) begin enable_crc_gen_o <= 3'b100; end
						else begin enable_crc_gen_o <= 3'b101; end
					end
				end
				SYNC: begin
					//CHANGE STATE
					sync_o <= 1;
					if(pulse_done_i) begin
    						state <= STATUS;
  					end
					if(done_pre_data_i) begin data_gen_crc_o <= saved_data_fast; end
					if(enable_crc_gen_o != 0) begin
						enable_crc_gen_o <= 0;
					end 
					//PRE DATA FAST && enable_i CRC DATA FAST
						case(saved_frame_format) 
							TWO_FAST_CHANNELS_12_12: begin 
								if(count_load == 0) begin load_bit_o <= 3'b001; count_load <= 1; end 
								if(done_pre_data_i) begin 	
									enable_crc_gen_o <= 3'b001; 
									load_bit_o <= 3'b000; 
									data_gen_crc_o <= saved_data_fast;
								end
							end
						
							ONE_FAST_CHANNELS_12: begin 
								if(count_load == 0) begin load_bit_o <= 3'b010; count_load <= 1; end 
								if(done_pre_data_i) begin 
									enable_crc_gen_o <= 3'b011; 
									load_bit_o <= 3'b000; 
								end
							end

							HIGH_SPEED_ONE_FAST_CHANNEL_12: begin 
								if(count_load == 0) begin load_bit_o <= 3'b011; count_load <= 1; end 
								if(done_pre_data_i) begin 
									enable_crc_gen_o <= 3'b010; 
									load_bit_o <= 3'b000; 
								end 
							end

							SECURE_SENSOR: begin 
								if(count_load == 0) begin load_bit_o <= 3'b100; count_load <= 1; end 
								if(done_pre_data_i) begin
									enable_crc_gen_o <= 3'b001; 
										load_bit_o <= 3'b000; 
								end
							end
						
							SINGLE_SENSOR_12_0: begin 
								if(count_load == 0) begin load_bit_o <= 3'b101; count_load <= 1; end 
								if(done_pre_data_i) begin 
									enable_crc_gen_o <= 3'b001; 
									load_bit_o <= 3'b000;
								end
							end
							TWO_FAST_CHANNELS_14_10: begin 
								if(count_load == 0) begin load_bit_o <= 3'b110; count_load <= 1; end 
								if(done_pre_data_i) begin 
									enable_crc_gen_o <= 3'b001; 
									load_bit_o <= 3'b000; 
								end
							end

							TWO_FAST_CHANNELS_16_8: begin 
								if(count_load == 0) begin load_bit_o <= 3'b111; count_load <= 1; end 
								if(done_pre_data_i) begin 
									enable_crc_gen_o <= 3'b001; 
									load_bit_o <= 3'b000; 
								end
							end	
						endcase
			
				end
				STATUS: begin
					count_load <= 0;
					//CONTROL pulse_o GEN
					sync_o <= 0;
					pulse_o <= 1;

					//TURN OFF enable_i CRC 
					if(enable_crc_gen_o != 0) enable_crc_gen_o <= 3'b000; 

					//CHANGE STATE
					if(!channel_format_i) begin
						data_nibble_o[2] <= saved_short_data[15];
						if(count_frame ==0) begin
							data_nibble_o[3] <= 1;
						end
						else data_nibble_o[3] <= 0;

						if(pulse_done_i) begin
    							state <= DATA;
							saved_short_data <= {saved_short_data[14:0], 1'b0};
  						end
					end
					else begin
						data_nibble_o[2] <= saved_enhanced_bit2[17];
						data_nibble_o[3] <= saved_enhanced_bit3[17];

						if(pulse_done_i) begin
    							state <= DATA;
							saved_enhanced_bit2 <= {saved_enhanced_bit2[16:0], 1'b0};
							saved_enhanced_bit3 <= {saved_enhanced_bit3[16:0], 1'b0};
  						end
					end
				end
				DATA: begin
					//CONTROL pulse_o GEN
					pulse_o <= 1;
					

					//CHANGE STATE
					if( (saved_frame_format == TWO_FAST_CHANNELS_12_12) || (saved_frame_format == SECURE_SENSOR)|| (saved_frame_format == SINGLE_SENSOR_12_0)||
					(saved_frame_format == TWO_FAST_CHANNELS_14_10) || (saved_frame_format == TWO_FAST_CHANNELS_16_8) ) begin
						data_nibble_o <= data_gen_crc_o[23:20];
						if(pulse_done_i) begin
    							count_nibble <= count_nibble + 1;
							data_gen_crc_o <= {data_gen_crc_o[19:0], 4'b0000};
  						end
					end
					else if(saved_frame_format == ONE_FAST_CHANNELS_12) begin 
						data_nibble_o <= data_gen_crc_o[11:8];
						if(pulse_done_i) begin
    							count_nibble <= count_nibble + 1;
							data_gen_crc_o <= {data_gen_crc_o[7:0], 4'b0000};
  						end
					end
					else if(saved_frame_format == HIGH_SPEED_ONE_FAST_CHANNEL_12) begin 
						data_nibble_o <= data_gen_crc_o[15:12];
						if(pulse_done_i) begin
    							count_nibble <= count_nibble + 1;
							data_gen_crc_o <= {data_gen_crc_o[11:0], 4'b0000};
  						end
					end
				end
				
				CRC: begin
					//ROLL BACK BIT COUNTER
					if((saved_frame_format == SECURE_SENSOR) && (bit_counter == 255)) bit_counter <= 0; 

					//CONTROL pulse_o GEN
					pulse_o <= 1;

					//CHANGE STATE
					data_nibble_o <= crc_gen_i[3:0];
					if(pulse_done_i) begin
    						pulse_o <= 0;
						if(optional_pause_i) state <= PAUSE;
						else begin
							if( (!channel_format_i && count_frame != 15) || (channel_format_i && count_frame != 17) ) begin
								state <= SYNC;
								count_frame <= count_frame + 1;
							end
							else begin 
								state <= IDLE; 
								idle_o <= 1; 
								//CONTROL pulse_o GEN
								pulse_o <= 0;
	
							end
						end		
					end
				end
				PAUSE: begin
					
					//CONTROL pulse_o GEN
					pause_o <= 1;

					//CHANGE STATE
					if(pulse_done_i) begin
    						pause_o <= 0;
						if( (!channel_format_i && count_frame != 15) || (channel_format_i && count_frame != 17) ) begin
								state <= SYNC;
								count_frame <= count_frame + 1;
							end			
							else begin 
								state <= IDLE; 
								idle_o <= 1; 
								//CONTROL pulse_o GEN
								pulse_o <= 0;	
							end
					end

				end

			endcase
		end
	end
	
	
	always @(posedge clk_tx or negedge reset_n_tx) begin	
		if(!reset_n_tx) begin
			count_nibble <= 0;
		end
		else begin
			if(state == DATA) begin
				if( (saved_frame_format == TWO_FAST_CHANNELS_12_12) || (saved_frame_format == SINGLE_SENSOR_12_0)||
					(saved_frame_format == TWO_FAST_CHANNELS_14_10) || (saved_frame_format == TWO_FAST_CHANNELS_16_8) ) begin
					if(count_nibble == 6) begin
						count_nibble <= 0;
						state <= CRC;
					end
					else state <= DATA;
				end
				else if((saved_frame_format == SECURE_SENSOR)) begin
					if(count_nibble == 6) begin
						count_nibble <= 0;
						state <= CRC;
						bit_counter <= bit_counter + 1;
					end
					else state <= DATA;
				end
				else if(saved_frame_format == ONE_FAST_CHANNELS_12) begin 
					if(count_nibble == 3) begin
						count_nibble <= 0;
						state <= CRC;
					end
					else state <= DATA;
				end
				else if(saved_frame_format == HIGH_SPEED_ONE_FAST_CHANNEL_12) begin 
					if(count_nibble == 4) begin
						count_nibble <= 0;
						state <= CRC;
					end
					else state <= DATA;
				end
			end
		end
	end
	
endmodule
