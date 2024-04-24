module Com_tb();

	logic clk, rst_n, snd_cmd, clr_cmd_rdy, send_resp;
	logic[15:0] comm_cmd;
	logic[7:0] resp, resp_in;
	wire TX, cmd_cmplt, comm_tx, RX, resp_sent, cmd_rdy, resp_rdy, clr_resp_rdy;
	wire[15:0] wrapper_cmd;
	int i;
	

	ComSender iComSender(.clk(clk), .rst_n(rst_n), .cmd(comm_cmd), .send_cmd(snd_cmd), .TX(comm_tx), .RX(TX), .cmd_sent(cmd_cmplt), .resp_rdy(resp_rdy), .resp(resp_in), .clr_resp_rdy(clr_resp_rdy));
	UART_wrapper iUART_Wrapper(.clk(clk), .rst_n(rst_n), .clr_cmd_rdy(clr_cmd_rdy), .cmd_rdy(cmd_rdy), .cmd(wrapper_cmd), .send_resp(send_resp), .resp(resp), .resp_sent(resp_sent), .RX(comm_tx), .TX(TX));
				 
	always 
		#5 clk = ~clk;
		
	initial begin
		rst_n = 1;
		#15;
		rst_n = 0;
		#15;
		
		clk = 0;
		rst_n = 0;
		snd_cmd = 0;
		clr_cmd_rdy = 0;
		send_resp = 0;
		comm_cmd = 0;
		resp = 0;
		
		#10;
		rst_n = 1;
        //test random numbers until fail
        //NO RESET
		for (i = 0; i < 25; i++) begin
			comm_cmd = $random;
			snd_cmd = 1;
			#10;
			snd_cmd = 0;
			while(!cmd_cmplt) begin
				#1;
			end
			if (comm_cmd != wrapper_cmd) begin
				$display("ERROR: cmd sent does not match the cmd recieved comm_cmd = 0x%x wrapper_cmd = 0x%x", comm_cmd, wrapper_cmd);
                $stop;
            end
			clr_cmd_rdy = 1;
			#10;
			clr_cmd_rdy = 0;
		end
        $display("YAHOO! All tests passed!");
		$finish;
	end
	
endmodule