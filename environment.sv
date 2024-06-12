`ifndef ENV
`define ENV

`include "driver.sv"
`include "packet.sv"
`include "interface.sv"
`include "scoreboard.sv"
`include "receiver.sv"
class environment;
    	driver drv;
	Packet pkt;
	receiver rcv;
	Scoreboard scb;
    	virtual INTF intf;

    	function new(virtual INTF intf);
       	 	scb = new();
		drv = new(pkt,intf, scb.driver_mbox);
		rcv = new(intf,scb.receiver_mbox);
    	endfunction
endclass

`endif 