module sent_rx_control(
	//clk and reset_n_rx
	input clk_rx,
	input reset_n_rx,
	
	//signals to pulse check block
	input [2:0] done_pre_data_i,

	//signals to crc check
	output reg [2:0] enable_crc_check_o,
	input [1:0] crc_check_done_i,
	input valid_data_serial_i,
	input valid_data_enhanced_i,
	input valid_data_fast_i,

	input [7:0] id_decode_i,
	input [15:0] data_decode_i,
	input channel_format_decode_i,
	output reg read_enable_store_o,
	input [11:0] data_i,

	input config_bit_decode_i,
	output reg config_bit_received_o,
	input pause_decode_i,
	output reg pause_received_o,
	output reg channel_format_received_o,

	output reg [7:0] id_received_o,
	output reg [15:0] data_received_o,
	output reg write_enable_rx_o,
	output reg [11:0] data_fast_o
	);

	//frame format of fast channels
	localparam TWO_FAST_CHANNELS_12_12 = 1;
	localparam ONE_FAST_CHANNELS_12 = 2;
	localparam HIGH_SPEED_ONE_FAST_CHANNEL_12 = 3;
	localparam SECURE_SENSOR = 4;
	localparam SINGLE_SENSOR_12_0 = 5;
	localparam TWO_FAST_CHANNELS_14_10 = 6;
	localparam TWO_FAST_CHANNELS_16_8 = 7;
	
	reg valid_data_fast_i_channel;
	reg [11:0] data_fast1_decode;
	reg [11:0] data_fast2_decode;
	
	reg [17:0] saved;
	reg count_enable;
	reg count_store;
	reg [5:0] count_frame;
	reg count_rx;
	reg [2:0] count_enable_rx;
	reg [2:0] frame_format;
	reg [5:0] count_check_done;
	reg done_all;

	reg channel_format;
	reg read_store_fifo;
	reg write_rx_fifo;
	reg [2:0] saved_frame_format;

	always @(*) begin
		case(data_decode_i)
			16'h001: frame_format = TWO_FAST_CHANNELS_12_12;
			16'h002: frame_format = ONE_FAST_CHANNELS_12;
			16'h003: frame_format = HIGH_SPEED_ONE_FAST_CHANNEL_12;
			16'h004: frame_format = SECURE_SENSOR;
			16'h005: frame_format = SINGLE_SENSOR_12_0;
			16'h006: frame_format = TWO_FAST_CHANNELS_14_10;
			16'h007: frame_format = TWO_FAST_CHANNELS_16_8;
			default: frame_format = 0;
		endcase
	end

	always @(posedge clk_rx or negedge reset_n_rx) begin
		if(!reset_n_rx) begin
			enable_crc_check_o <= 0;
			read_enable_store_o <= 0;
			saved <= 0;
			count_store <= 0;
			count_enable <= 0;
			data_fast1_decode <= 0;
			data_fast2_decode <= 0;
			valid_data_fast_i_channel <= 0;
			count_frame <= 0;
			write_enable_rx_o <= 0;
			data_fast1_decode <= 0;
			data_fast2_decode <= 0;
			data_fast_o <= 0;
			id_received_o <= 0;
				data_received_o <= 0;
				pause_received_o <= 0;
				channel_format_received_o <= 0;
				config_bit_received_o <= 0;
			done_all <= 0;
			channel_format <= 0;
			read_store_fifo <= 0;
			saved_frame_format <= 0;
		end
		else begin
			//DONE PRE DATA FROM PULSE CHECK BLOCK -> TURN ON ENABLE CRC CHECK
			case(done_pre_data_i) 
				3'b001: begin enable_crc_check_o <= 3'b001; end
				3'b010: begin enable_crc_check_o <= 3'b010; end
				3'b011: begin enable_crc_check_o <= 3'b011; end
				3'b100: begin enable_crc_check_o <= 3'b100; channel_format <= 0; end
				3'b101: begin enable_crc_check_o <= 3'b101; channel_format <= 1; end
			endcase
			
			if(enable_crc_check_o != 0 ) begin enable_crc_check_o <= 0; count_check_done <= count_check_done + 1; end	

			//CHECK VALID DATA
			if(valid_data_serial_i || valid_data_enhanced_i) begin
				id_received_o <= id_decode_i;
				data_received_o <= data_decode_i;
				pause_received_o <= pause_decode_i;
				channel_format_received_o <= channel_format_decode_i;
				config_bit_received_o <= config_bit_decode_i;
			end


			//SAVED VALID DATA FAST		
			if(crc_check_done_i == 2'b01) begin saved <= {saved[16:0], valid_data_fast_i}; end
	
			//DEFINE FRAME FORMAT
			if(done_all) begin saved_frame_format <= frame_format; end
		end
	end
	
	//transmit data to fifo rx
	always @(posedge clk_rx or negedge reset_n_rx) begin
		if(!reset_n_rx) begin
			enable_crc_check_o <= 0;
			count_rx <= 0;
			count_enable_rx <= 0;
			count_check_done <= 0;
			write_rx_fifo <= 0;
		end
		else begin
			
			//ALL DONE
			if(!channel_format_decode_i && count_check_done == 17) begin done_all <= 1; read_store_fifo <= 1; count_check_done <= 0; end
			else if(channel_format_decode_i && count_check_done == 19) begin done_all <= 1; read_store_fifo <= 1; count_check_done <= 0; end

			//WRITE DATA TO RX FIFO
			case(saved_frame_format)
				TWO_FAST_CHANNELS_12_12: begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							if(!count_rx) begin
								data_fast_o <= data_fast1_decode; 
								count_rx <= 1; 
							end else begin 
								data_fast_o <= {data_fast2_decode[3:0],data_fast2_decode[7:4],data_fast2_decode[11:8]}; 
								count_rx <= 0; 
								write_rx_fifo <= 0;
								read_store_fifo <= 1;
							end
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end

				ONE_FAST_CHANNELS_12 : begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							data_fast_o <= data_fast1_decode[11:0]; 
							write_rx_fifo <= 0;
							read_store_fifo <= 1;
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end

				HIGH_SPEED_ONE_FAST_CHANNEL_12: begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							data_fast_o <= data_fast1_decode[11:0]; 
							write_rx_fifo <= 0;
							read_store_fifo <= 1;
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end

				SECURE_SENSOR: begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							if(!count_rx) begin
								data_fast_o <= data_fast1_decode; 
								count_rx <= 1; 
							end else begin 
								count_rx <= 0; 
								write_rx_fifo <= 0;
								read_store_fifo <= 1;
							end
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end

				SINGLE_SENSOR_12_0: begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							if(!count_rx) begin
								data_fast_o <= data_fast1_decode; 
								count_rx <= 1; 
							end else begin 
								count_rx <= 0; 
								write_rx_fifo <= 0;
								read_store_fifo <= 1;
							end
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end

				TWO_FAST_CHANNELS_14_10: begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							if(!count_rx) begin
								data_fast_o <= {data_fast1_decode}; 
								count_rx <= 1; 
							end else begin 
								data_fast_o <= {data_fast2_decode[3:0],data_fast2_decode[7:4],data_fast2_decode[9:8]}; 
								count_rx <= 0; 
								write_rx_fifo <= 0;
								read_store_fifo <= 1;
							end
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end
				
				TWO_FAST_CHANNELS_16_8: begin
					if(write_rx_fifo) begin
						if(count_enable_rx) begin
							write_enable_rx_o <= 1;
							count_enable_rx <= 0;
							if(!count_rx) begin
								data_fast_o <= data_fast1_decode; 
								count_rx <= 1; 
							end else begin 
								data_fast_o <= {data_fast2_decode[11:8],data_fast2_decode[3:0],data_fast2_decode[7:4]}; 
								count_rx <= 0; 
								write_rx_fifo <= 0;
								read_store_fifo <= 1;
							end
						end
						else begin count_enable_rx <= count_enable_rx + 1; end
					end
				end
			endcase
			
			if(write_enable_rx_o) write_enable_rx_o <= 0;
		end
	end

	//READ DATA FROM STORE FIFO
	always @(posedge clk_rx or negedge reset_n_rx) begin
		if(!reset_n_rx) begin

		end
		else begin
			if(crc_check_done_i != 0) begin enable_crc_check_o <= 0; end
			if(read_enable_store_o) begin read_enable_store_o <= 0; end

			if(done_all) begin
				if((saved_frame_format == TWO_FAST_CHANNELS_12_12) || (saved_frame_format == SECURE_SENSOR) || (saved_frame_format == SINGLE_SENSOR_12_0) ||
				(saved_frame_format == TWO_FAST_CHANNELS_14_10) || (saved_frame_format == TWO_FAST_CHANNELS_16_8) ) begin
					if(read_store_fifo) begin
						if( (channel_format && count_frame != 18) || (!channel_format  && count_frame != 16) ) begin
							if(count_enable) begin
								count_enable <= 0;
								read_enable_store_o <= 1;
								if(!count_store) begin
									data_fast1_decode <= data_i;
									count_store <= 1;
								end
								else begin
									data_fast2_decode <= data_i; 
									count_store <= 0; 
									valid_data_fast_i_channel <= saved[17];
									saved <= {saved[16:0], valid_data_fast_i};
									count_frame <= count_frame + 1;
									write_rx_fifo <= 1;
									read_store_fifo <= 0;
									
								end
							end else count_enable <= count_enable + 1;
						end 
						else begin 
							read_enable_store_o <= 0; 
							valid_data_fast_i_channel <= 0; 
							count_frame <= 0; 
							done_all <= 0; 
							read_store_fifo <= 0;
						end
					end	
				end
				else if ( (saved_frame_format == ONE_FAST_CHANNELS_12) || (saved_frame_format == HIGH_SPEED_ONE_FAST_CHANNEL_12) )  begin
					if(read_store_fifo) begin
						if(channel_format && count_frame != 18 || (!channel_format && count_frame != 16) ) begin
							if(count_enable) begin
								count_enable <= 0;
								read_enable_store_o <= 1;
								data_fast1_decode <= data_i;
								valid_data_fast_i_channel <= saved[17];
								saved <= {saved[16:0], valid_data_fast_i};
								count_frame <= count_frame + 1;
								write_rx_fifo <= 1;
								read_store_fifo <= 0;
							end else count_enable <= count_enable + 1;
						end 
						else begin 
							read_enable_store_o <= 0; 
							valid_data_fast_i_channel <= 0; 
							count_frame <= 0; 
							done_all <= 0; 
							read_store_fifo <= 0;
						end
					end	
				end
			end
			else read_enable_store_o <= 0;
		end
	end
endmodule
