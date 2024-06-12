`ifndef RCV
`define RCV
`include"packet.sv"
`include "interface.sv"
class receiver;
	Packet pktcmp = new;
	
	typedef mailbox #(Packet) rx_box_type;
       	rx_box_type receiver_mbox = new;

    	virtual INTF intf;
	
    	function new (virtual INTF intf, rx_box_type receiver_mbox);

		this.intf = intf;	
		this.receiver_mbox = receiver_mbox;
    	endfunction
  
	task run();
        forever begin
        // @(posedge intf.clk)
        @(posedge intf.valid) begin
            pktcmp.PWDATA_i = intf.data_o;
			receiver_mbox.put(pktcmp);
		end
		
        end
	endtask
endclass
`endif 