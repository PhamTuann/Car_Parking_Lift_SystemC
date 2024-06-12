`ifndef SCO
`define SCO
`include"driver.sv"
`include"interface.sv"
class Scoreboard;	// unique identifier
    	virtual INTF intf;
	Packet pkt = new();
	
	typedef mailbox #(Packet) out_box_type;
       	out_box_type driver_mbox;
	
	Packet pktcmp = new();
	real cov1;
	typedef mailbox #(Packet) rx_box_type;
       	rx_box_type receiver_mbox;
	
	function new (out_box_type driver_mbox =null, rx_box_type receiver_mbox=null);	
			if (driver_mbox == null) 
	       driver_mbox = new();
       	if (receiver_mbox == null) 
	       receiver_mbox = new();
        this.driver_mbox = driver_mbox;
        this.receiver_mbox = receiver_mbox;
    	endfunction
	

	task check();
        forever begin
        //@(posedge apb_i2c_io.valid) begin
            // $display("Checking");
            if(receiver_mbox.try_get(pktcmp)) begin
			       $display ($time, "[SCOREBOARD] Grabbing Data From both Driver and Receiver");
			       //receiver_mbox.get(pkt2cmp);
			       driver_mbox.get(pkt);
				if (pktcmp.PWDATA_i != pkt.PWDATA_i) begin
				
			       		$display($time, "ns : [ERROR] :((((((((((((( Data transmitted %x", pktcmp.PWDATA_i);
					$display($time, "ns : [ERROR] :((((((((((((( Data out slave %x", pkt.PWDATA_i);
				end
		       end
		       else 
		       begin
			       #1;
		       end

		
		
        end
    endtask

endclass
`endif 