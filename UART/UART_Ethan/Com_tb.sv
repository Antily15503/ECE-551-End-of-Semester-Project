module Com_tb ();
//instantiating signals
reg clk, rst_n;
reg [15:0] cmdIN, cmdOUT;
wire [7:0] resp;
reg snd_cmd, cmd_sent, resp_rdy, cmd_rdy, clr_cmd_rdy, send_resp;
reg TX_RX, RX_TX;

//instantiating DUTs
ComSender iDUTCom(.cmd(cmdIN), .snd_cmd(snd_cmd), .clk(clk), .rst_n(rst_n), .RX(RX_TX), .resp(resp), .resp_rdy(resp_rdy), .cmd_sent(cmd_sent), .TX(TX_RX));
UART_wrapper iDUTUART(.RX(TX_RX), .TX(RX_TX), .clk(clk), .rst_n(rst_n), .clr_cmd_rdy(clr_cmd_rdy), .send_resp(send_resp), .resp(resp), .cmd_rdy(cmd_rdy), .resp_sent(resp_sent), .cmd(cmdOUT));

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    snd_cmd = 1'b0;
    clr_cmd_rdy = 1'b0;
    send_resp = 1'b0;
    @ (posedge clk) rst_n = 1'b1;

    //test 1: sending a string of 4 command and seeing if it appears on the other side
    for (int i = 1; i < 5; i=i+1) begin
        @ (posedge clk) cmdIN = i * 8'hBB;
        @ (posedge clk) snd_cmd = 1'b1;
        @ (posedge clk) snd_cmd = 1'b0;
        //checking for activation of cmd_rdy signal
        fork
            begin : timeout1CR
                repeat (10000) @(posedge clk);
                $display("TIMED OUT: timed out waiting for cmd_rdy in UART_wrapper to be asserted");
                $stop();
            end
            begin
                @ (posedge  cmd_rdy) begin
                    disable timeout1CR;
                end
            end
        join
        if (cmdIN !== cmdOUT) begin
            $display("FAILED: part %d of test 1 did not recieve expected value for cmdOUT. Expected %h but recieved %h", i, cmdIN, cmdOUT);
            $stop();
        end else $display("PASSED: part %d of test 1 passed!", i);

        //wait until cmd has finished sending
        @ (posedge cmd_sent);
        //clear reset to prepare for next value
        @ (posedge clk) clr_cmd_rdy = 1'b1;
        @ (posedge clk) clr_cmd_rdy = 1'b0;
    end
$display("All tests passed! Exiting testbench");
$stop();
end


always #4 clk = ~clk;

endmodule