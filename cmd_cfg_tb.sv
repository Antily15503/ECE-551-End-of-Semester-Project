module cmd_cfg_tb();

  // Parameters from the cmd_cfg module
  localparam ENTRIES = 384;
  localparam LOG2 = 9;

  // Testbench Signals
  logic clk,rst_n,cmd_rdy,resp_sent,set_capture_done,send_resp,clr_cmd_rdy, clr_resp_rdy;
  logic [15:0] cmd_in, cmd;
  logic [LOG2-1:0] waddr;
  logic [7:0] rdataCH1,rdataCH2,rdataCH3,rdataCH4,rdataCH5, wdata;
  logic [7:0] resp, resp_out;
  logic [LOG2-1:0] raddr, trig_pos;
  logic [3:0] decimator;
  logic [7:0] maskL,maskH;
  logic [7:0] matchL,matchH;
  logic [7:0] baud_cntL,baud_cntH;
  logic [5:0] TrigCfg;
  logic [4:0] CH1TrigCfg,CH2TrigCfg,CH3TrigCfg,CH4TrigCfg,CH5TrigCfg;
  logic [7:0] VIH,VIL;
  
logic snd_cmd,cmd_snt,resp_rdy,TX_RX,RX_TX;

// Instantiating the sender and wrapper 
UART_wrapper iDUTWrapper(.cmd(cmd), .cmd_rdy(cmd_rdy), .clr_cmd_rdy(clr_cmd_rdy)
, .clk(clk), .rst_n(rst_n), .RX(TX_RX), .TX(RX_TX), .resp(resp), .send_resp(send_resp), .resp_sent(resp_sent));

ComSender iDUTCom(.cmd(cmd_in), .send_cmd(snd_cmd), .cmd_sent(cmd_snt), .clk(clk)
, .rst_n(rst_n), .RX(RX_TX), .TX(TX_RX), .resp(resp_out), .resp_rdy(resp_rdy), .clr_resp_rdy(clr_resp_rdy));

RAMqueue RAM1 (.clk(clk), .we(we), .waddr(waddr), .wdata(wdata), .raddr(raddr), .rdata(rdata));

  // DUT Instantiation
cmd_cfg #(.ENTRIES(ENTRIES),.LOG2(LOG2)) iDUTCmd (
    .clk(clk),.rst_n(rst_n),.cmd(cmd),.cmd_rdy(cmd_rdy),.resp_sent(resp_sent),.set_capture_done(set_capture_done),
    .waddr(waddr),.rdataCH1(rdataCH1),.rdataCH2(rdataCH2),.rdataCH3(rdataCH3),.rdataCH4(rdataCH4),.rdataCH5(rdataCH5),
    .resp(resp),.send_resp(send_resp),.clr_cmd_rdy(clr_cmd_rdy),.raddr(raddr),.trig_pos(trig_pos),.decimator(decimator),
    .maskL(maskL),.maskH(maskH),.matchL(matchL),.matchH(matchH),.baud_cntL(baud_cntL),.baud_cntH(baud_cntH),
    .TrigCfg(TrigCfg),.CH1TrigCfg(CH1TrigCfg),.CH2TrigCfg(CH2TrigCfg),.CH3TrigCfg(CH3TrigCfg),.CH4TrigCfg(CH4TrigCfg),
    .CH5TrigCfg(CH5TrigCfg),.VIH(VIH),.VIL(VIL));

  // Initial Setup and Tests
  initial begin
    // Reset the system
    rst_n = 0;
	clk = 0;
    cmd_in = 0;
    snd_cmd = 0;
    resp_sent = 0;
    set_capture_done = 0;
    waddr = 0;
    rdataCH1 = 0;
    rdataCH2 = 0;
    rdataCH3 = 0;
    rdataCH4 = 0;
    rdataCH5 = 0;

    @(negedge clk) rst_n = 1;

    // Test 0: Test response with invalid command

    @ (posedge clk) cmd_in = '1;
    @ (posedge clk) snd_cmd = 1'b1;
    @(posedge clk); snd_cmd = 1'b0; 
    fork
        begin : negTimeout
            repeat (10000) @(posedge clk);
            $display("Time out: send_resp was never asserted");
            $stop();
        end
        begin
            @ (posedge resp_rdy) begin
                disable negTimeout;
                @ (posedge clk);
                if (resp_out !== 8'hEE) begin
                    $display ("Test 0 failed: program did not assert negative acknowledgement of 0xEE");
                    $stop();
                end else begin 
                    $display("Test 0 passed!");
                end
            end
            @ (posedge clk) clr_resp_rdy = 1;
            @ (posedge clk) clr_resp_rdy = 0;
        end
    join

    // Test 1: Write Command to TrigCfg and verify
    cmd_in = {2'b01, 6'h00, 8'hAA}; 
    snd_cmd = 1'b1;
    @(posedge clk); 
    snd_cmd = 1'b0; // Clear command ready after the command is latched
    fork
        begin : trigcfgTimeout
            repeat (100000) @(posedge clk);
            $display("Time out: send_resp was never asserted [test 1]");
            $stop();
        end
        begin
                @ (posedge resp_rdy) begin
                    disable trigcfgTimeout;
                    if (resp_out !== 8'hA5) begin
                        $display("Test case 1 failed: Incorrect response on write command");
                        $stop();
                    end else $display("Test 1 passed!");
            end
            @ (posedge clk) clr_resp_rdy = 1;
            @ (posedge clk) clr_resp_rdy = 0;
        end
    join

    // Test 2: Read TrigConfig and see if written command(AA) is written
    cmd_in = {2'b00, 6'h00, 8'hAA}; 
    snd_cmd = 1'b1;
    @(posedge clk); 
    snd_cmd = 1'b0; // Clear command ready after the command is latched
    fork
        begin : ReadTrigCfg
            repeat (100000) @(posedge clk);
            $display("Time out: send_resp was never asserted [test 2]");
            $stop();
        end
        begin  
            @ (posedge resp_rdy) begin
                disable ReadTrigCfg;
                if (TrigCfg !== 6'hAA) begin
                        $display("Test case 2 failed: TrigCfg not written correctly");	
                        $stop();
                    end else $display("Test 2 passed!");
            end
        end
    join 

    // Test 3: Testing the Dump command of cmd_cfg
	waddr = 9'b10;
    @ (posedge clk);
    cmd_in = {2'b10, 6'h01, 8'hAA}; 
    snd_cmd = 1'b1;
    @(posedge clk); 
    snd_cmd = 1'b0; // Clear command ready after the command is latched
    fork
        begin : dumpTimeout
            repeat (300000) @(posedge clk);
            $display("Time out: dumping function's addr_ptr never rolled over / reached waddr [test 3]");
            $stop();
        end
        begin
            while (raddr !== waddr) begin
                repeat (10) @(posedge clk);
            end
            disable dumpTimeout;
            $display("Dump passed!");
            @ (posedge clk) clr_resp_rdy = 1;
            @ (posedge clk) clr_resp_rdy = 0;
        end
    join
    $display("All tests completed successfully.");
    $finish;
  end
    always #5 clk = ~clk; // clock generation

endmodule