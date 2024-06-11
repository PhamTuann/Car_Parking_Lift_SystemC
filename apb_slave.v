module apb_slave 
	#(parameter ADDRESSWIDTH= 3,
	parameter DATAWIDTH= 16)

	(
	input PCLK,
	input PRESETn,
	input [ADDRESSWIDTH-1:0]PADDR_i,
	input [DATAWIDTH-1:0] PWDATA_i,
	input PWRITE_i,
	input PSELx_i,
	input PENABLE_i,
	output reg [DATAWIDTH-1:0] PRDATA_o,
	output PREADY_o,

	//REGISTER
	output reg [7:0] reg_command_tx,		//RW
	output reg [11:0] reg_transmit_tx,	//RW
	output reg [7:0] reg_id_tx,		//RW
	output reg [15:0] reg_data_field_tx,		//RW

	input [11:0] reg_receive_rx,		//READ ONLY
	input [7:0] reg_id_rx,			//READ ONLY
	input [15:0] reg_data_field_rx,		//READ ONLY
	input [7:0] reg_command_rx,

	input [7:0] reg_status_tx_rx,		//READ ONLY
 
	//output control fifo tx
	output reg write_enable_tx,
	output reg read_enable_rx
	
	);
	assign PREADY_o = 1;
	always @(posedge PCLK or negedge PRESETn) begin
 		if(!PRESETn) begin
			PRDATA_o <= 0;
			reg_command_tx <= 0;
			reg_transmit_tx <= 0; 
			reg_id_tx <= 0;
			reg_data_field_tx <= 0;
			write_enable_tx <= 0;
			read_enable_rx <= 0;
		end
		else begin
			if (PENABLE_i & PWRITE_i & PSELx_i) begin
				case (PADDR_i)
				
					1: reg_command_tx <= PWDATA_i[7:0];
					2: begin
						if(!reg_status_tx_rx[7]) begin	
							reg_transmit_tx <= PWDATA_i[11:0];
						end
						
					end
					3: reg_id_tx <= PWDATA_i[7:0];
					4: reg_data_field_tx <= PWDATA_i[15:0];
					default: reg_transmit_tx <= PWDATA_i[11:0];
				endcase
			end

			if (PWRITE_i & PADDR_i == 2) begin
				write_enable_tx <= PENABLE_i;
			end

			if(PENABLE_i & !PWRITE_i & PSELx_i) begin
				case (PADDR_i)
					1: PRDATA_o <= reg_command_tx;
					2: begin
						if(!reg_status_tx_rx[6]) begin	
							PRDATA_o <= reg_transmit_tx;
						end
						
					end
					3: PRDATA_o <= reg_id_tx;
					4: PRDATA_o <= reg_data_field_tx;
					5: begin
						if(!reg_status_tx_rx[4]) begin	
							PRDATA_o <= reg_receive_rx;
						end
					end
					6: PRDATA_o <= reg_id_rx;
					7: PRDATA_o <= reg_data_field_rx;
					8: PRDATA_o <= reg_status_tx_rx;
					9: PRDATA_o <= reg_command_rx;
					default: PRDATA_o <= 0;
				endcase
			end

			if (!PWRITE_i & PADDR_i == 5) read_enable_rx <= PENABLE_i;
		end
	end
endmodule