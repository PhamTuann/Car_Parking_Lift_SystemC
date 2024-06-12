`ifndef DRIVER
`define DRIVER
`include"packet.sv"
`include "interface.sv"
class driver;
	Packet pkt;
	
	typedef mailbox #(Packet) out_box_type;
       	out_box_type driver_mbox = new;
 
    	virtual INTF intf;
	
	covergroup COVER@(posedge intf.PCLK);
	REG_COV: coverpoint intf.PADDR_i {
			bins prescaler = {8'h00};
			bins cmd = {8'h01};
			bins trasnmit = {8'h02};
			bins receive = {8'h03};
			bins address = {8'h04};
			bins status = {8'h05};
			
		}
	PWRITE_i_COV: coverpoint intf.PWRITE_i;

	RW_REG_COV: cross REG_COV, PWRITE_i_COV {
		option.cross_auto_bin_max = 0;
		bins read_prescaler = binsof(REG_COV.prescaler) && binsof(PWRITE_i_COV) intersect{0};
		bins read_cmd = binsof(REG_COV.cmd) && binsof(PWRITE_i_COV) intersect{0};
		bins read_trasnmit = binsof(REG_COV.trasnmit) && binsof(PWRITE_i_COV) intersect{0};
		bins read_receive = binsof(REG_COV.receive) && binsof(PWRITE_i_COV) intersect{0};
		bins read_address = binsof(REG_COV.address) && binsof(PWRITE_i_COV) intersect{0};
		bins read_status = binsof(REG_COV.status) && binsof(PWRITE_i_COV) intersect{0};

		bins write_prescaler = binsof(REG_COV.prescaler) && binsof(PWRITE_i_COV) intersect{1};
		bins write_cmd = binsof(REG_COV.cmd) && binsof(PWRITE_i_COV) intersect{1};
		bins write_trasnmit = binsof(REG_COV.trasnmit) && binsof(PWRITE_i_COV) intersect{1};
		bins write_address = binsof(REG_COV.address) && binsof(PWRITE_i_COV) intersect{1};
	}
 
	PWDATA_i_COV: coverpoint intf.PWDATA_i {
		bins data = {[0:7]};
		bins address_w = {8'h20};
		bins address_r = {8'h21};
	}
	
	endgroup 

    	function new (Packet pkt, virtual INTF intf, out_box_type driver_mbox);
       	 	this.pkt = pkt;	
		this.intf = intf;	
		this.driver_mbox = driver_mbox;
		COVER = new ();
    	endfunction
	real cov1;
	task reset();
		$display ($time, "ns:  [RESET] Reset Start");
		intf.PRESETn = 0; 
		repeat(10) @(intf.PCLK);
		intf.PRESETn = 1;
		$display ($time, "ns:  [RESET] Reset End");
	endtask

	

	task write_reg(input bit [7:0] PADDR_i, reg [15:0] PWDATA_i);
		pkt = new();
		$display ($time, "ns:  [WRITE REG] Start");
		intf.PWRITE_i = 1;
		intf.PSELx_i = 1;
		//pkt.PADDR_i = PADDR_i;
		intf.PADDR_i = PADDR_i;
		@(posedge intf.PCLK);
		intf.PWDATA_i = PWDATA_i;
		intf.PENABLE_i = 1;
		@(posedge intf.PCLK);
		intf.PSELx_i = 0;
		intf.PENABLE_i = 0;
		if(PADDR_i == 8'h02) begin
			pkt.PWDATA_i = PWDATA_i;
			driver_mbox.put(pkt);
		end
		@(posedge intf.PCLK);
		$display($time, "ns:  [WRITE DONE] Data %x to reg %x", PWDATA_i, PADDR_i);
	
	endtask

	task read_reg(input bit [7:0] PADDR_i);
		pkt = new ();
		$display ($time, "ns:  [READ REG] Start");
		intf.PWRITE_i = 0;
		intf.PSELx_i = 1;
		intf.PADDR_i = PADDR_i;
		@(posedge intf.PCLK);
		intf.PENABLE_i = 1;
		@(posedge intf.PCLK);
		intf.PSELx_i = 0;
		intf.PENABLE_i = 0;
		@(posedge intf.PCLK);
		$display($time, "ns:  [READ Done] Data %x read from reg %x", intf.PWDATA_i, PADDR_i);
	endtask

	


  

endclass
`endif 