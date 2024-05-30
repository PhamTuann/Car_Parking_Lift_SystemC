module sent_tx_top(
	//clk_tx and reset_n_tx
	input clk_tx,	
	input reset_n_tx,
	input channel_format_i, //0: serial, 1: enhanced
	input optional_pause_i,
	input config_bit_i,
	input enable_i,
	input [7:0] id_i,
	input [15:0] data_bit_field_i,
	input [11:0] data_fast_i,
	input fifo_tx_empty_i,
	output read_enable_tx_o,
	output data_pulse_o
	);

	//----------SENT TX------------------//
	//control block <-> crc block
	wire [2:0] enable_crc_gen_io;
	wire [23:0] data_gen_crc_io;
	wire [5:0] crc_gen_io;
	wire [1:0] crc_gen_done_io;

	//gen ticks block <-> pulse gen block
	wire ticks_io;

	//control block <-> pulse gen block
	wire [3:0] data_nibble_io;
	wire pulse_io;
	wire sync_io;
	wire pause_io;
	wire pulse_done_io;
	wire idle_io;

	//data reg block <-> control block
	wire [2:0] load_bit_io;
	wire done_pre_data_io;
	wire [15:0] data_f1_io;
	wire [11:0] data_f2_io;
	//----------SENT TX------------------//
	
	sent_tx_data_reg sent_tx_data_reg(
		//clk_tx and reset_n_tx
		.clk_tx(clk_tx),
		.reset_n_tx(reset_n_tx),

		//signals to control block
		.load_bit_i(load_bit_io),
		.done_pre_data_o(done_pre_data_io),
		.data_f1_o(data_f1_io),
		.data_f2_o(data_f2_io),

		//signals to fifo
		.data_fast_i(data_fast_i),
		.read_enable_tx_o(read_enable_tx_o),
		.fifo_tx_empty_i(fifo_tx_empty_i)
	);

	sent_tx_control sent_tx_control(
		//clk_tx and reset_n_tx
		.clk_tx(clk_tx),
		.reset_n_tx(reset_n_tx),

		//normal input
		.channel_format_i(channel_format_i), //0: serial(), 1: enhanced
		.optional_pause_i(optional_pause_i),
		.config_bit_i(config_bit_i),
		.enable_i(enable_i),
		.id_i(id_i),
		.data_bit_field_i(data_bit_field_i),

		//signals to crc block
		.enable_crc_gen_o(enable_crc_gen_io),
		.data_gen_crc_o(data_gen_crc_io),
		.crc_gen_done_i(crc_gen_done_io),
		.crc_gen_i(crc_gen_io),

		//signals to pulse gen block
		.pulse_done_i(pulse_done_io),
		.data_nibble_o(data_nibble_io),
		.pulse_o(pulse_io),
		.sync_o(sync_io),
		.pause_o(pause_io),
		.idle_o(idle_io),
	
		//signals to data reg block
		.data_f1_i(data_f1_io),
		.data_f2_i(data_f2_io),
		.load_bit_o(load_bit_io),
		.done_pre_data_i(done_pre_data_io)
	);

	sent_tx_pulse_gen sent_tx_pulse_gen(
		//clk_tx and reset_n_tx
		.ticks_i(ticks_io),
		.reset_n_tx(reset_n_tx),

		//signals to control
		.data_nibble_i(data_nibble_io),
		.pulse_i(pulse_io),
		.sync_i(sync_io),
		.pause_i(pause_io),
		.idle_i(idle_io),
		.pulse_done_o(pulse_done_io),

		//output
		.data_pulse_o(data_pulse_o)
	);

	sent_tx_gen_ticks sent_tx_gen_ticks(
		.clk_tx(clk_tx),
		.reset_n_tx(reset_n_tx),
		.ticks_o(ticks_io)
	);

	sent_tx_crc_gen sent_tx_crc_gen(
		.clk_tx(clk_tx),
		.reset_n_tx(reset_n_tx),
		.crc_gen_o(crc_gen_io),
		.enable_crc_gen_i(enable_crc_gen_io),
		.data_gen_crc_i(data_gen_crc_io),
		.crc_gen_done_o(crc_gen_done_io)
	);
endmodule
