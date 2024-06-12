`include "environment.sv"
`timescale 1ns/1ns

program testcase(INTF intf);
    environment env = new(intf);
    initial begin
	fork begin
        env.drv.reset();
       // env.drv.write_reg(8'h00, 8'b00000100);    //prescale
	env.drv.write_reg(8'h01, 8'b11100000);		//reset
        env.drv.write_reg(8'h03, 8'h05); 
	env.drv.write_reg(8'h04, 16'h001);  
	//addresss
        env.drv.write_reg(8'h02, 12'h001);	//data
	env.drv.write_reg(8'h02, 12'h002);	//data
	env.drv.write_reg(8'h02, 12'h003);
	env.drv.write_reg(8'h02, 12'h004);
	env.drv.write_reg(8'h02, 12'h005);
	env.drv.write_reg(8'h02, 12'h006);	env.drv.write_reg(8'h02, 12'h007);
	env.drv.write_reg(8'h02, 12'h008);	//data
	env.drv.write_reg(8'h02, 12'h009);	//data
	env.drv.write_reg(8'h02, 12'h00a);
	env.drv.write_reg(8'h02, 12'h00b);
	env.drv.write_reg(8'h02, 12'h00c);
	env.drv.write_reg(8'h02, 12'h00d);	env.drv.write_reg(8'h02, 12'h00e);
	env.drv.write_reg(8'h02, 12'h00f);	//data
	env.drv.write_reg(8'h02, 12'h010);	//data
	env.drv.write_reg(8'h02, 12'h011);
	env.drv.write_reg(8'h02, 12'h012);
	env.drv.write_reg(8'h02, 12'h013);
	env.drv.write_reg(8'h02, 12'h014);	env.drv.write_reg(8'h02, 12'h015);
	env.drv.write_reg(8'h02, 12'h016);
	env.drv.write_reg(8'h02, 12'h017);
	env.drv.write_reg(8'h02, 12'h018);
	env.drv.write_reg(8'h02, 12'h019);	env.drv.write_reg(8'h02, 12'h020);
	env.drv.write_reg(8'h02, 12'h021);
	env.drv.write_reg(8'h02, 12'h022);
	env.drv.write_reg(8'h02, 12'h023);
	env.drv.write_reg(8'h02, 12'h024);
	env.drv.write_reg(8'h02, 12'h025);	env.drv.write_reg(8'h02, 12'h026);

	env.drv.write_reg(8'h01, 8'b11110000);
	#20;
	env.drv.write_reg(8'h01, 8'b11100000);
	#1000;
	end
 env.rcv.run();
	env.scb.check();
	join_any
	
        #5000000;
       $finish;
    end
endprogram     