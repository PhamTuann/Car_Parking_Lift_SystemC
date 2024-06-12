`ifndef ASSERT
`define ASSERT

module assertion_cov(INTF intf);
    // PREADY CHECK
    	PREADY_CHECK: cover property (@(posedge intf.PCLK) (intf.PSELx_i && !intf.PENABLE_i) |=> (intf.PENABLE_i) |-> (intf.PREADY_o));
 
    	WRITE_CHECK: cover property (@(posedge intf.PCLK) ((intf.PWRITE_i) |-> (intf.PADDR_i ==  8'h00 || intf.PADDR_i ==  8'h01 || intf.PADDR_i ==  8'h02 || intf.PADDR_i ==  8'h04 )));
	 
	READ_CHECK: cover property (@(posedge intf.PCLK) ((!intf.PWRITE_i) |-> (intf.PADDR_i)));
	 
	PRESETn_CHECK: cover property (@(posedge intf.PCLK) (!intf.PRESETn) |-> intf.PREADY_o && !intf.PRDATA_o);
	
    
endmodule
`endif 