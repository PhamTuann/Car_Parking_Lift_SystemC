module top
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
	output [DATAWIDTH-1:0] PRDATA_o,
	output PREADY_o,
		
	input clk_tx,
	input clk_rx
	);
	
	//REGISTER
	wire [7:0] reg_command_tx;		//RW
	wire [11:0] reg_transmit_tx;		//RW
	wire [7:0] reg_id_tx;			//RW
	wire [15:0] reg_data_field_tx;		//RW
	wire [11:0] reg_receive_rx;		//READ ONLY
	wire [7:0] reg_id_rx;			//READ ONLY
	wire [15:0] reg_data_field_rx; 		//READ ONLY
	wire [7:0] reg_status_tx_rx;
	wire [7:0] reg_command_rx;
	assign reg_command_rx[4:0] = 4'b0000;
	assign reg_status_tx_rx[3:0] = 4'b0000;
	//APB <-> FIFO TX AND RX
	wire write_enable_tx;
	wire read_enable_rx_io;
    wire read_enable_tx_io;
	wire [11:0] data_fast_io;
	wire fifo_tx_empty_io;
	assign fifo_tx_empty_io = reg_status_tx_rx[6];
	wire data_pulse_io;
	wire write_enable_rx_io;

	wire [11:0] data_fast_out;

	apb_slave apb_slave(
		.PCLK(PCLK),
		.PRESETn(PRESETn),
		.PADDR_i(PADDR_i),
		.PWDATA_i(PWDATA_i),
		.PWRITE_i(PWRITE_i),
		.PSELx_i(PSELx_i),
		.PENABLE_i(PENABLE_i),
		.PRDATA_o(PRDATA_o),
		.PREADY_o(PREADY_o),
		.reg_command_tx(reg_command_tx),  
		.reg_transmit_tx(reg_transmit_tx), 
		.reg_id_tx(reg_id_tx), 
		.reg_data_field_tx(reg_data_field_tx),
		.reg_receive_rx(reg_receive_rx),  
		.reg_id_rx(reg_id_rx), 
		.reg_data_field_rx(reg_data_field_rx), 
		.reg_status_tx_rx(reg_status_tx_rx),
		.reg_command_rx(reg_command_rx),
		.write_enable_tx(write_enable_tx),
		.read_enable_rx(read_enable_rx_io)
	);

	async_fifo tx_fifo(
		.write_enable(write_enable_tx), 
		.write_clk(PCLK), 
		.write_reset_n(PRESETn),
		.read_enable(read_enable_tx_io), 
		.read_clk(clk_tx), 
		.read_reset_n(PRESETn),
		.write_data(reg_transmit_tx),
		.read_data(data_fast_io),
		.write_full(reg_status_tx_rx[7]),
		.read_empty(reg_status_tx_rx[6])
	);
	
	sent_tx_top sent_tx_top(
	//clk and reset
		.clk_tx(clk_tx),	
		.reset_n_tx(PRESETn),
		.channel_format_i(reg_command_tx[7]), //0: serial(), 1: enhanced
		.optional_pause_i(reg_command_tx[6]),
		.config_bit_i(reg_command_tx[5]),
		.enable_i(reg_command_tx[4]),
		.id_i(reg_id_tx),
		.data_bit_field_i(reg_data_field_tx),
		.data_pulse_o(data_pulse_io),
		.read_enable_tx_o(read_enable_tx_io),
		.data_fast_i(data_fast_io),
		.fifo_tx_empty_i(fifo_tx_empty_io)
	);

	sent_rx_top sent_rx_top(
		.clk_rx(clk_rx),
		.reset_n_rx(PRESETn),
		.data_pulse_i(data_pulse_io),
		.write_enable_rx_o(write_enable_rx_io),
		.id_received_o(reg_id_rx),
		.data_received_o(reg_data_field_rx),
		.data_fast_o(data_fast_out),
		.channel_format_received_o(reg_command_rx[7]),
		.pause_received_o(reg_command_rx[6]),
		.config_bit_received_o(reg_command_rx[5])
	);
	
	async_fifo rx_fifo(
		.write_enable(write_enable_rx_io), 
		.write_clk(clk_rx), 
		.write_reset_n(PRESETn),
		.read_enable(read_enable_rx_io), 
		.read_clk(PCLK), 
		.read_reset_n(PRESETn),
		.write_data(data_fast_out),
		.read_data(reg_receive_rx),
		.write_full(reg_status_tx_rx[5]),
		.read_empty(reg_status_tx_rx[4])
	);

endmodule