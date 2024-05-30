`timescale 1ns/1ns
module test_top;

	localparam ADDRESSWIDTH= 3;
	localparam DATAWIDTH= 16;
	
	reg PCLK;
	reg PRESETn;
	reg [ADDRESSWIDTH-1:0]PADDR_i;
	reg [DATAWIDTH-1:0] PWDATA_i;
	reg PWRITE_i;
	reg PSELx_i;
	reg PENABLE_i;
	wire [DATAWIDTH-1:0] PRDATA_o;
	wire PREADY_o;
		
	reg clk_tx;
	reg clk_rx;

	top dut(
		.PCLK(PCLK),
		.PRESETn(PRESETn),
		.PADDR_i(PADDR_i),
		.PWDATA_i(PWDATA_i),
		.PWRITE_i(PWRITE_i),
		.PSELx_i(PSELx_i),
		.PENABLE_i(PENABLE_i),
		.PRDATA_o(PRDATA_o),
		.PREADY_o(PREADY_o),
		
		.clk_tx(clk_tx),
		.clk_rx(clk_rx)
	);


	initial begin
		PCLK = 0;
		forever begin
			PCLK = #1 ~PCLK;
		end		
	end
	initial begin
		clk_tx = 0;
		forever begin
			clk_tx = #2 ~clk_tx;
		end		
	end
	initial begin
		clk_rx = 0;
		forever begin
			clk_rx = #2 ~clk_rx;
		end		
	end
	initial begin
		PCLK = 0;
		PRESETn = 0;
		PADDR_i = 0;
		PWDATA_i = 0;
		PWRITE_i = 0; 
		PSELx_i = 0;
		PENABLE_i = 0;
		#5
       		PRESETn = 1;
		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h001;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	
		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h002;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	
		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h003;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	
		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h004;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	

		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h005;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	
		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h006;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	
		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h007;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	

		//transmit data 1
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h008;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;	
		//transmit data 2 
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h009;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 3
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h00a;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 4
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h00b;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 5
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h00c;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 6
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h00d;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 7
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h00e;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h00f;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h010;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h011;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;

		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h012;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h013;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h014;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h015;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h016;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0; 
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h017;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h018;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h019;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h01a;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h01b;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h01c;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h01d;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h01e;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h01f;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h020;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h021;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h022;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h023;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h024;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h025;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h026;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h027;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h028;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h029;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h02a;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 2;
		PWDATA_i = 12'h02a;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 3;
		PWDATA_i = 8'h55;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 4;
		PWDATA_i = 16'h0001;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#2
		PADDR_i = 1;
		PWDATA_i = 8'b11100000;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#10
		PADDR_i = 1;
		PWDATA_i = 8'b11110000;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		//transmit data 8
		#10
		PADDR_i = 1;
		PWDATA_i = 8'b11100000;
		PWRITE_i = 1; 
		PSELx_i = 1;
		#2
		PENABLE_i = 1;
		#2
		PENABLE_i = 0;
		PSELx_i = 0;
		#1000000;
		$finish;
	end   
endmodule
