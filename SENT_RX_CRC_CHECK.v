module sent_rx_crc_check(
	//reset_n_rx
	input clk_rx,
	input reset_n_rx,

	//signals to control block
	
	input [2:0] enable_crc_check_i,
	output reg [1:0] crc_check_done_o,
	input [29:0] data_check_crc_i,
	output reg valid_data_serial_o,
	output reg valid_data_enhanced_o,
	output reg valid_data_fast_o
	);
	reg [5:0] lfsr_q; //current state
	reg [5:0] lfsr_c; //next state
	always @(*) begin
		case(enable_crc_check_i)
		3'b001: begin
			lfsr_c[0] = lfsr_q[0] ^ data_check_crc_i[26] ^ data_check_crc_i[25] ^ data_check_crc_i[21] ^ 
				data_check_crc_i[19] ^ data_check_crc_i[18] ^ data_check_crc_i[14] ^ data_check_crc_i[12] ^
				data_check_crc_i[11] ^ data_check_crc_i[7] ^ data_check_crc_i[5] ^ data_check_crc_i[4] ^ data_check_crc_i[0];

			lfsr_c[1] = lfsr_q[3] ^ data_check_crc_i[27] ^ data_check_crc_i[26] ^ data_check_crc_i[22] ^ 
					data_check_crc_i[20] ^ data_check_crc_i[19] ^ data_check_crc_i[15] ^ data_check_crc_i[13] ^ 
					data_check_crc_i[12] ^ data_check_crc_i[8] ^ data_check_crc_i[6] ^ data_check_crc_i[5] ^ data_check_crc_i[1]; 

			lfsr_c[2] = lfsr_q[0] ^ lfsr_q[2] ^ data_check_crc_i[27] ^ data_check_crc_i[26] ^ data_check_crc_i[25] ^ 
					data_check_crc_i[23] ^ data_check_crc_i[20] ^ data_check_crc_i[19] ^ data_check_crc_i[18] ^ 
					data_check_crc_i[16] ^ data_check_crc_i[13] ^ data_check_crc_i[11] ^ data_check_crc_i[9] ^
					data_check_crc_i[6] ^ data_check_crc_i[5] ^ data_check_crc_i[4] ^ data_check_crc_i[2]; 
	
			lfsr_c[3] =  lfsr_q[1] ^ data_check_crc_i[27] ^ data_check_crc_i[25] ^ data_check_crc_i[24] ^ 
					data_check_crc_i[20] ^ data_check_crc_i[18] ^ data_check_crc_i[17] ^ data_check_crc_i[13] ^ 
					data_check_crc_i[11] ^ data_check_crc_i[10] ^ data_check_crc_i[6] ^ data_check_crc_i[4] ^ data_check_crc_i[3];
			lfsr_c[5:4] = 2'b00;
		end
		3'b100, 3'b011: begin
			lfsr_c[0] = lfsr_q[1] ^ lfsr_q[2] ^ data_check_crc_i[14] ^ data_check_crc_i[12] ^ 
					data_check_crc_i[11] ^ data_check_crc_i[7] ^ data_check_crc_i[5] ^ data_check_crc_i[4] ^ data_check_crc_i[0] ;

			lfsr_c[1] = lfsr_q[1] ^ data_check_crc_i[27] ^ data_check_crc_i[13] ^ data_check_crc_i[12] 
					^ data_check_crc_i[8] ^ data_check_crc_i[6] ^ data_check_crc_i[5] ^ data_check_crc_i[1];

			lfsr_c[2] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ data_check_crc_i[13] ^ data_check_crc_i[12] 
					^ data_check_crc_i[11] ^ data_check_crc_i[9] ^ data_check_crc_i[6] ^ data_check_crc_i[5] 
					^ data_check_crc_i[4] ^ data_check_crc_i[2] ;
	
			lfsr_c[3] =  lfsr_q[2] ^ lfsr_q[3] ^ data_check_crc_i[13] ^ data_check_crc_i[11] ^ data_check_crc_i[10] 
					^ data_check_crc_i[6] ^ data_check_crc_i[4] ^ data_check_crc_i[3];
			lfsr_c[5:4] = 2'b00;
		end
		3'b010: begin
			lfsr_c[0] = lfsr_q[3] ^ data_check_crc_i[19] ^ data_check_crc_i[18] ^ data_check_crc_i[14] ^ 
					data_check_crc_i[12] ^ data_check_crc_i[11] ^ data_check_crc_i[7] ^ data_check_crc_i[5] 
					^ data_check_crc_i[4] ^ data_check_crc_i[0];

			lfsr_c[1] = lfsr_q[0] ^ lfsr_q[2] ^ data_check_crc_i[19] ^ data_check_crc_i[15] ^ data_check_crc_i[13] 
					^ data_check_crc_i[12] ^ data_check_crc_i[8] ^ data_check_crc_i[6] ^ data_check_crc_i[5] ^ data_check_crc_i[1]; 

			lfsr_c[2] = lfsr_q[0] ^ lfsr_q[1] ^ data_check_crc_i[19] ^ data_check_crc_i[18] ^ data_check_crc_i[16] 
					^ data_check_crc_i[15] ^ data_check_crc_i[12] ^ data_check_crc_i[11] ^ data_check_crc_i[9] 
					^ data_check_crc_i[6] ^ data_check_crc_i[5] ^ data_check_crc_i[4] ^ data_check_crc_i[2]; 
	
			lfsr_c[3] =  lfsr_q[0] ^ data_check_crc_i[16] ^ data_check_crc_i[17] ^ data_check_crc_i[13] ^ data_check_crc_i[11] 
					^ data_check_crc_i[10] ^ data_check_crc_i[6] ^ data_check_crc_i[4] ^ data_check_crc_i[3];
			lfsr_c[5:4] = 2'b00;
		end
		3'b101: begin
			lfsr_c[0] = data_check_crc_i[12] ^ data_check_crc_i[17] ^ data_check_crc_i[10] ^ data_check_crc_i[22] ^ data_check_crc_i[15] ^ data_check_crc_i[23] ^ data_check_crc_i[8] ^ data_check_crc_i[20] ^ data_check_crc_i[13] ^ lfsr_q[1] ^ data_check_crc_i[9] ^ data_check_crc_i[28] ^ data_check_crc_i[21] ^ data_check_crc_i[27] ^ data_check_crc_i[6] ^ data_check_crc_i[0];
			lfsr_c[1] = data_check_crc_i[13] ^ data_check_crc_i[18] ^ data_check_crc_i[11] ^ data_check_crc_i[23] ^ data_check_crc_i[16] ^ data_check_crc_i[24] ^ data_check_crc_i[9] ^ data_check_crc_i[21] ^ data_check_crc_i[14] ^ lfsr_q[2] ^ data_check_crc_i[10] ^ data_check_crc_i[29] ^ data_check_crc_i[22] ^ data_check_crc_i[28] ^ data_check_crc_i[7] ^ data_check_crc_i[1];
			lfsr_c[2] = data_check_crc_i[14] ^ data_check_crc_i[19] ^ data_check_crc_i[12] ^ data_check_crc_i[24] ^ data_check_crc_i[17] ^ data_check_crc_i[25] ^ data_check_crc_i[10] ^ data_check_crc_i[22] ^ data_check_crc_i[15] ^ lfsr_q[3] ^ data_check_crc_i[11] ^ lfsr_q[0] ^ data_check_crc_i[23] ^ data_check_crc_i[29] ^ data_check_crc_i[8] ^ data_check_crc_i[2];
			lfsr_c[3] = data_check_crc_i[17] ^ data_check_crc_i[10] ^ data_check_crc_i[22] ^ data_check_crc_i[8] ^ data_check_crc_i[28] ^ data_check_crc_i[21] ^ data_check_crc_i[27] ^ data_check_crc_i[6] ^ data_check_crc_i[25] ^ data_check_crc_i[18] ^ data_check_crc_i[26] ^ data_check_crc_i[11] ^ data_check_crc_i[16] ^ lfsr_q[4] ^ data_check_crc_i[24] ^ lfsr_q[0] ^ data_check_crc_i[3];
			lfsr_c[4] = data_check_crc_i[10] ^ data_check_crc_i[15] ^ data_check_crc_i[8] ^ data_check_crc_i[20] ^ data_check_crc_i[13] ^ data_check_crc_i[21] ^ data_check_crc_i[6] ^ data_check_crc_i[18] ^ data_check_crc_i[11] ^ data_check_crc_i[29] ^ data_check_crc_i[7] ^ data_check_crc_i[26] ^ data_check_crc_i[19] ^ lfsr_q[5] ^ data_check_crc_i[25] ^ data_check_crc_i[4];
			lfsr_c[5] = data_check_crc_i[11] ^ data_check_crc_i[16] ^ data_check_crc_i[9] ^ data_check_crc_i[21] ^ data_check_crc_i[14] ^ data_check_crc_i[22] ^ data_check_crc_i[7] ^ data_check_crc_i[19] ^ data_check_crc_i[12] ^ lfsr_q[0] ^ data_check_crc_i[8] ^ data_check_crc_i[27] ^ data_check_crc_i[20] ^ data_check_crc_i[26] ^ data_check_crc_i[5];
		end
		default: lfsr_c = lfsr_q;
		endcase
	end

	always @(posedge clk_rx or negedge reset_n_rx) begin
		if(!reset_n_rx) begin
			lfsr_q <= 6'b010101;
			lfsr_q <= 0;
			valid_data_enhanced_o <= 0;
			valid_data_serial_o  <= 0;
		 	valid_data_fast_o <= 0;
		 	crc_check_done_o <= 0;
		end
		else begin
			case(enable_crc_check_i)
				3'b001, 3'b010, 3'b011: begin
					crc_check_done_o <= 2'b01;
					if(lfsr_c == 0) begin
						valid_data_fast_o <= 1;
					end
				end
				3'b100: begin
					if(lfsr_c == 0) begin
						valid_data_serial_o <= 1;
					end
				end
				3'b101: begin
					if(lfsr_c == 0) begin
						valid_data_enhanced_o <= 1;
					end
				end
			endcase
			if(enable_crc_check_i != 0) begin
				lfsr_q <= 6'b010101;
			end
			if(valid_data_enhanced_o || valid_data_serial_o || valid_data_fast_o || crc_check_done_o) begin
					valid_data_enhanced_o <= 0;
					valid_data_serial_o <= 0;
					valid_data_fast_o <=0;
					crc_check_done_o <= 0; 
			end
		end	
	end
			
endmodule
