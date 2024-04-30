`timescale 1ns / 100ps

//// Interconnects to DUT/support defined as type wire /////
wire clk400MHz,locked;			// PLL output signals to DUT
wire clk;						// 100MHz clock generated at this level from clk400MHz
wire VIH_PWM,VIL_PWM;			// connect to PWM outputs to monitor
wire CH1L,CH1H,CH2L,CH2H,CH3L;	// channel data inputs from AFE model
wire CH3H,CH4L,CH4H,CH5L,CH5H;	// channel data inputs from AFE model
wire RX,TX;						// interface to host
wire cmd_sent,resp_rdy;			// from master UART, monitored in test bench
wire [7:0] resp;				// from master UART, reponse received from DUT
wire tx_prot;					// UART signal for protocol triggering
wire SS_n,SCLK,MOSI;			// SPI signals for SPI protocol triggering
wire CH1L_mux,CH1H_mux;         // output of muxing logic for CH1 to enable testing of protocol triggering
wire CH2L_mux,CH2H_mux;			// output of muxing logic for CH2 to enable testing of protocol triggering
wire CH3L_mux,CH3H_mux;			// output of muxing logic for CH3 to enable testing of protocol triggering

////// Stimulus is declared as type reg ///////
reg REF_CLK, RST_n;
reg [15:0] host_cmd;			// command host is sending to DUT
reg send_cmd;					// asserted to initiate sending of command
reg clr_resp_rdy;				// asserted to knock down resp_rdy
reg [1:0] clk_div;				// counter used to derive 100MHz clk from clk400MHz
reg strt_tx;					// kick off unit used for protocol triggering
reg en_AFE;
reg capture_done_bit;			// flag used in polling for capture_done
reg [7:0] res,exp;				// used to store result and expected read from files

wire AFE_clk;

///////////////////////////////////////////
// Channel Dumps can be written to file //
/////////////////////////////////////////
integer fptr1;		// file pointer for CH1 dumps
// more file handles for dumps of other channels??? //
integer fexp;		// file pointer to file with expected results
integer found_res,found_expected,loop_cnt;
integer mismatches;	// number of mismatches when comparing results to expected
integer sample;		// sample counter in dump & compare

/////////////////////////////////
logic UART_triggering = 1'b0;	// set to true if testing UART based triggering
logic SPI_triggering = 1'b0;	// set to true if testing SPI based triggering

//test bench signals for UART_tx_cfg_bd
logic [7:0] UART_tx_cfg_bd_data, uart_match;
logic tx_done;
logic [15:0] spi_tx_data, spi_match;

module LA_dig_tb_tasks();


assign AFE_clk = en_AFE & clk400MHz;
///// Instantiate Analog Front End model (provides stimulus to channels) ///////
AFE iAFE(.smpl_clk(AFE_clk),.VIH_PWM(VIH_PWM),.VIL_PWM(VIL_PWM),
         .CH1L(CH1L),.CH1H(CH1H),.CH2L(CH2L),.CH2H(CH2H),.CH3L(CH3L),
         .CH3H(CH3H),.CH4L(CH4L),.CH4H(CH4H),.CH5L(CH5L),.CH5H(CH5H));
		 
//// Mux for muxing in protocol triggering for CH1 /////
assign {CH1H_mux,CH1L_mux} = (UART_triggering) ? {2{tx_prot}} :		// assign to output of UART_tx used to test UART triggering
                             (SPI_triggering) ? {2{SS_n}}: 			// assign to output of SPI SS_n if SPI triggering
				             {CH1H,CH1L};

//// Mux for muxing in protocol triggering for CH2 /////
assign {CH2H_mux,CH2L_mux} = (SPI_triggering) ? {2{SCLK}}: 			// assign to output of SPI SCLK if SPI triggering
				             {CH2H,CH2L};	

//// Mux for muxing in protocol triggering for CH3 /////
assign {CH3H_mux,CH3L_mux} = (SPI_triggering) ? {2{MOSI}}: 			// assign to output of SPI MOSI if SPI triggering
				             {CH3H,CH3L};					  
	 
////// Instantiate DUT ////////		  
LA_dig iDUT(.clk400MHz(clk400MHz),.RST_n(RST_n),.locked(locked),
            .VIH_PWM(VIH_PWM),.VIL_PWM(VIL_PWM),.CH1L(CH1L_mux),.CH1H(CH1H_mux),
			.CH2L(CH2L_mux),.CH2H(CH2H_mux),.CH3L(CH3L_mux),.CH3H(CH3H_mux),.CH4L(CH4L),
			.CH4H(CH4H),.CH5L(CH5L),.CH5H(CH5H),.RX(RX),.TX(TX), .LED());

///// Instantiate PLL to provide 400MHz clk from 50MHz ///////
pll8x iPLL(.ref_clk(REF_CLK),.RST_n(RST_n),.out_clk(clk400MHz),.locked(locked));

///// It is useful to have a 100MHz clock at this level similar //////
///// to main system clock (clk).  So we will create one        //////
always @(posedge clk400MHz, negedge locked)
  if (~locked)
    clk_div <= 2'b00;
  else
    clk_div <= clk_div+1;
assign clk = clk_div[1];

//// Instantiate Master UART (mimics host commands) //////
ComSender iSNDR(.clk(clk), .rst_n(RST_n), .RX(TX), .TX(RX),
                .cmd(host_cmd), .send_cmd(send_cmd),
		.cmd_sent(cmd_sent), .resp_rdy(resp_rdy),
		.resp(resp), .clr_resp_rdy(clr_resp_rdy));
					 
////////////////////////////////////////////////////////////////
// Instantiate transmitter as source for protocol triggering //
//////////////////////////////////////////////////////////////

logic [15:0] uart_baud;

UART_tx_cfg_bd iTX(.clk(clk), .rst_n(RST_n), .TX(tx_prot), .trmt(strt_tx),
            .tx_data(UART_tx_cfg_bd_data), .tx_done(tx_done), .baud(uart_baud));	// 921600 Baud
					 
////////////////////////////////////////////////////////////////////
// Instantiate SPI transmitter as source for protocol triggering //
//////////////////////////////////////////////////////////////////
SPI_TX iSPI(.clk(clk),.rst_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),.wrt(strt_tx),.done(done),
            .tx_data(spi_tx_data),.MOSI(MOSI),.pos_edge(1'b0),.width8(1'b0));

initial begin
  fptr1 = $fopen("CH1dmp.txt","w");			// open file to write CH1 dumps to

  en_AFE = 0;
  strt_tx = 0;						// do not initiate protocol trigger for now
  
  //// Initialization////
  rst_init();

  ////// Set for CH1 triggering on positive edge //////
	send_command(16'h4110);
	
  ////// Leave all other registers at their default /////
  ////// and set RUN bit, but enable AFE first //////
  en_AFE = 1;
  send_command(16'h4013);		// set the run bit, keep protocol triggering off

  //// Now read trig config polling for capture_done bit to be set ////
  polling_done();

  //// Now request CH1 dump ////
  send_command({8'h81,8'h00});

  //turn on uart triggering so uart_cfg_bd has time to clear
  UART_triggering = 1'b1;	


  //// Now collect CH1 dump into a file ////
    /// task??? ////
  channel_dump();
  
  repeat(10) @(posedge clk);
  $fclose(fptr1);
  

  //stop dumping
  send_command(16'h0000);
  UART_triggering = 1'b1;	


  //// Now compare CH1dmp.txt to expected results ////
  dump_compare();
  $display("Channel Trig Test Passed");
  repeat(400) @(posedge clk);



  //TEST 2: testing UART_triggering
  uart_match = 8'h1A;
  uart_baud = 16'h006C;

  ////// Disable CH1 Triggering //////
  send_command(16'h4101);
  ////// Set Baud L//////
  send_command({2'b01, 6'h0E, {uart_baud[7:0]}});
  ////// Set Baud H//////
  send_command({2'b01, 6'h0D, {uart_baud[15:8]}});
  ////// Set run bit, enable uart triggering//////
  send_command(16'h4012);
  ////// Setting maskL //////
  send_command({2'b01, 6'h0A, {uart_match}});
  ////// Setting match bits to 0000 //////
  send_command({2'b01, 6'h0C, 8'h00});
  uart_trig_polling();

  $display("UART Test 1 Passed");
  repeat(400) @(posedge clk);

  //Test again with different baud, different match
  uart_match = 8'h22;
  uart_baud = 16'h002F;

  ////// Set Baud L//////
  send_command({2'b01, 6'h0E, {uart_baud[7:0]}});
  ////// Set Baud H//////
  send_command({2'b01, 6'h0D, {uart_baud[15:8]}});
  ////// Set run bit, enable uart triggering//////
  send_command(16'h4012);
  ////// Setting maskL //////
  send_command({2'b01, 6'h0A, {uart_match}});
  uart_trig_polling();



  $display("UART Test 2 Passed");

  repeat(400) @(posedge clk);



  //TEST 3: Testing SPI Triggering
  UART_triggering = 0;
  SPI_triggering = 1;
  spi_match = 16'h001A;


  //16 bit word, neg edge trigger
  send_command({2'b01, 6'h00, 8'h15});
  ////// Setting maskL //////
  send_command({2'b01, 6'h0A, {spi_match[7:0]}});
  ////// Setting maskH bits to 0x00 //////
  send_command({2'b01, 6'h0B, {spi_match[15:8]}});
  ////// Setting matchL bits to 0000 //////
  send_command({2'b01, 6'h0C, 8'h00});
  ////// Setting matchH bits to 0000 //////
  send_command({2'b01, 6'h09, 8'h00});
  spi_trig_polling();

  $display("Spi Test 1 Passed");
  repeat(400) @(posedge clk);


  //Test again with different match, pos edge trigger
  spi_match = 16'h0100;
  //16 bit word, neg edge trigger
  send_command({2'b01, 6'h00, 8'h11});
  ////// Setting maskL //////
  send_command({2'b01, 6'h0A, {spi_match[7:0]}});
  ////// Setting maskH bits to 0x00 //////
  send_command({2'b01, 6'h0B, {spi_match[15:8]}});
  spi_trig_polling();
  $display("SPI Test 2 Passed");


  $display("YAHOO! ALL TESTS PASSED!");
  
  $stop();
end



always
  #100 REF_CLK = ~REF_CLK;

endmodule	

task dump_compare();
  fexp = $fopen("test1_expected.txt","r");
  fptr1 = $fopen("CH1dmp.txt","r");
  found_res = $fscanf(fptr1,"%h",res);
  found_expected = $fscanf(fexp,"%h",exp);
  sample = 1;
  mismatches = 0;
  while (found_expected==1) begin
    if (res!==exp)
	  begin
	    $display("At sample %d the result of %h does not match expected of %h",sample,res,exp);
		mismatches = mismatches + 1;
		if (mismatches>100) begin
		  $display("ERR: Too many mismatches...stopping test1");
		  $stop();
		end
	  end
	sample = sample + 1;
    found_res = $fscanf(fptr1,"%h",res);
    found_expected = $fscanf(fexp,"%h",exp);
  end	
endtask

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
    @(posedge cmd_sent);
    @(posedge clk);

	end
endtask
task wait_resp();	
	begin
		@(posedge resp_rdy)
	    if (resp&8'h20)				// capture_done bits set?
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
            // wait for command to be sent 
            @(posedge cmd_sent);
	    // Call wait_resp task
	    wait_resp();
	  end
	end
endtask


task uart_trig_polling();
	begin

    logic [15:0] uart_cmd;
    uart_cmd = 16'b0;
		capture_done_bit = 1'b0;			// capture_done not set yet
	  loop_cnt = 0;
  	while (!capture_done_bit)
	  begin
	    repeat(400) @(posedge clk);		// delay a while between reads
	    loop_cnt = loop_cnt + 1;
      uart_cmd = uart_cmd + 1;
	    if (loop_cnt>200) begin
	      $display("ERROR: capture done bit never set");
	      $stop();
	    end
            UART_tx_cfg_bd_data = uart_cmd;

            strt_tx = 1'b1;
            @(posedge clk);
            strt_tx = 1'b0;
            @(posedge tx_done);
            @(posedge clk);

            host_cmd = 16'd0;	// read TRIG_CFG which has capture_done bit
            @(posedge clk);
            send_cmd = 1;
            @(posedge clk);
            send_cmd = 0;
            // wait for command to be sent 
            @(posedge cmd_sent);
	    // Call wait_resp task
	    wait_resp();
	  end

    if(uart_cmd != uart_match) begin
      $display("Error: UART triggerd off bad cmd, %h", uart_cmd);
      $stop;
    end
  
	end
endtask



task spi_trig_polling();
	begin

    logic [15:0] spi_cmd;
    spi_cmd = 16'b0;
		capture_done_bit = 1'b0;			// capture_done not set yet
	  loop_cnt = 0;
  	while (!capture_done_bit)
	  begin
	    repeat(400) @(posedge clk);		// delay a while between reads
	    loop_cnt = loop_cnt + 1;
      spi_cmd = spi_cmd + 1;
	    if (loop_cnt>200) begin
	      $display("ERROR: capture done bit never set");
	      $stop();
	    end
            spi_tx_data = spi_cmd;

            strt_tx = 1'b1;
            @(posedge clk);
            strt_tx = 1'b0;
            @(posedge tx_done);
            @(posedge clk);

            host_cmd = 16'd0;	// read TRIG_CFG which has capture_done bit
            @(posedge clk);
            send_cmd = 1;
            @(posedge clk);
            send_cmd = 0;
            // wait for command to be sent 
            @(posedge cmd_sent);
	    // Call wait_resp task
	    wait_resp();
	  end

    if(spi_cmd != spi_match) begin
      $display("Error: SPI triggerd off bad cmd, %h", spi_cmd);
      $stop;
    end
  
	end
endtask

task channel_dump();
    for (sample=0; sample<384; sample++)
      fork
        begin: timeout1
	      repeat(6000) @(posedge clk);
	      $display("ERR: Only received %d of 384 bytes on dump",sample);
		  $stop();
	      sample = 384;		// break out of loop
	    end
	    begin
	      @(posedge resp_rdy);
	      disable timeout1;
              $fdisplay(fptr1,"%h",resp);	// write to CH1dmp.txt
	      clr_resp_rdy = 1;
	      @(posedge clk);
	      clr_resp_rdy = 0;
	    end
      join

endtask



