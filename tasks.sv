task rst_init();	
	begin
		send_cmd = 0;
		REF_CLK = 0;
		RST_n = 0;						// assert reset
		repeat (2) @(posedge REF_CLK);
		@(negedge REF_CLK);				// on negedge REF_CLK after a few REF clocks
		RST_n = 1;						// deasert reset
		@(negedge REF_CLK);
	end
endtask

task send_command(input [15:0] cmd2send);	
	begin
		host_cmd = cmd2send;		
		@(posedge clk);
		send_cmd = 1;
		@(posedge clk);
		send_cmd = 0;
	end
endtask

task wait_resp();	
	begin
		@(posedge resp_rdy)
	    if (resp&8'h20)				// is capture_done bits set?
	      capture_done_bit = 1'b1;
	    clr_resp_rdy = 1;
	    @(posedge clk);
	    clr_resp_rdy = 0;
	end
endtask

task polling_done();	
	begin
		capture_done_bit = 1'b0;			// capture_done not set yet
	loop_cnt = 0;
	/// This whole polling for capture done should be a task ///
  	while (!capture_done_bit)
	  begin
	    repeat(400) @(posedge clk);		// delay a while between reads
	    loop_cnt = loop_cnt + 1;
	    if (loop_cnt>200) begin
	      $display("ERROR: capture done bit never set");
	      $stop();
	    end
            host_cmd = {8'h00,8'h00};	// read TRIG_CFG which has capture_done bit
            @(posedge clk);
            send_cmd = 1;
            @(posedge clk);
            send_cmd = 0;
            // Now wait for command to be sent // 
            @(posedge cmd_sent);
	    // Call wait response task
	    wait_resp();
	  end
	$display("INFO: capture_done bit is set");
	end
endtask


