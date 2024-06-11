module sent_rx_top(
	input clk_rx,
	input reset_n_rx,
	input data_pulse_i,
	output write_enable_rx_o,
	output [7:0] id_received_o,
	output channel_format_received_o,
	output pause_received_o,
	output config_bit_received_o,
	output [15:0] data_received_o,	
	output [11:0] data_fast_o
	);
	
	//----------SENT RX------------------//
	//pulse check block <-> crc check block
	wire [29:0] data_check_crc_io;

	//pulse check block <-> store fifo
	wire [11:0] data_out;
	wire write_enable_store_io;

	//pulse check block <-> rx control
	wire [2:0] done_pre_data_io;
	wire [7:0] id_decode_io;
	wire [15:0] data_decode_io;
	wire channel_format_decode_io;
	wire pause_decode_io;
	wire config_bit_decode_io;

	//rx control <-> store fifo
	wire [11:0] data_fast_in;
	wire read_enable_store_io;

	//rx control <-> crc check
	wire [2:0] enable_crc_check_io;
	wire valid_data_serial_io;
	wire valid_data_enhanced_io;
	wire valid_data_fast_io;
	wire [1:0] crc_check_done_io;

	sent_rx_pulse_check sent_rx_pulse_check(
		.clk_rx(clk_rx),
		.reset_n_rx(reset_n_rx),
		.data_pulse_i(data_pulse_i),
		.data_check_crc_o(data_check_crc_io),
		.done_pre_data_o(done_pre_data_io),
		.id_decode_o(id_decode_io),
		.data_decode_o(data_decode_io),
		.write_enable_store_o(write_enable_store_io),
		.data_o(data_out),
		.channel_format_decode_o(channel_format_decode_io),
		.pause_decode_o(pause_decode_io),
		.config_bit_decode_o(config_bit_decode_io)
	);

	async_fifo store_fifo(
		.write_enable(write_enable_store_io), 
		.write_clk(clk_rx), 
		.write_reset_n(reset_n_rx),
		.read_enable(read_enable_store_io), 
		.read_clk(clk_rx), 
		.read_reset_n(reset_n_rx),
		.write_data(data_out),
		.read_data(data_fast_in),
		.write_full(write_full),
		.read_empty(read_empty)
	);

	sent_rx_crc_check sent_rx_crc_check(
		.clk_rx(clk_rx),
		.reset_n_rx(reset_n_rx),
		//signals to control block
		.enable_crc_check_i(enable_crc_check_io),
		.data_check_crc_i(data_check_crc_io),
		.valid_data_serial_o(valid_data_serial_io),
		.valid_data_enhanced_o(valid_data_enhanced_io),
		.valid_data_fast_o(valid_data_fast_io),
		.crc_check_done_o(crc_check_done_io)

	);
	
	sent_rx_control sent_rx_control(
		.clk_rx(clk_rx),
		.reset_n_rx(reset_n_rx),
		.done_pre_data_i(done_pre_data_io),
		.enable_crc_check_o(enable_crc_check_io),
		.valid_data_serial_i(valid_data_serial_io),
		.valid_data_enhanced_i(valid_data_enhanced_io),
		.valid_data_fast_i(valid_data_fast_io),
		.id_decode_i(id_decode_io),
		.pause_decode_i(pause_decode_io),
		.config_bit_decode_i(config_bit_decode_io),
		.channel_format_decode_i(channel_format_decode_io),
		.data_decode_i(data_decode_io),
		.read_enable_store_o(read_enable_store_io),
		.data_i(data_fast_in),
		.write_enable_rx_o(write_enable_rx_o),
		.data_fast_o(data_fast_o),
		.id_received_o(id_received_o),
		.data_received_o(data_received_o),
		.channel_format_received_o(channel_format_received_o),
		.pause_received_o(pause_received_o),
		.config_bit_received_o(config_bit_received_o),
		.crc_check_done_i(crc_check_done_io)
	);

endmodule
