`ifndef INF
`define INF
`timescale 1ns/1ns
interface INTF(input PCLK, input clk_tx, input clk_rx);
	
	logic PRESETn;
	logic [2:0]PADDR_i;
	logic [15:0] PWDATA_i;
	logic PWRITE_i;
	logic PSELx_i;
	logic PENABLE_i;
	wire [15:0] PRDATA_o;
	wire PREADY_o;
	wire [11:0] data_o;
	wire valid;
	
endinterface

`endif 