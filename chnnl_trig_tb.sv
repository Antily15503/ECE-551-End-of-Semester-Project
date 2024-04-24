module chnnl_trig_tb();
//chnnl_trig logic signals
logic clk, rst_n, armed, CH_Lff5, CH_Hff5, CH_Trig;
logic [4:0] CH_TrigCfg;
//connecting logic signals
chnnl_trig iDUT(.clk(clk), .rst_n(rst_n), .CH_trigCfg(CH_TrigCfg), .armed(armed), .CH_Lff5(CH_Lff5), .CH_Hff5(CH_Hff5), .CH_Trig(CH_Trig));

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    CH_TrigCfg = '0;
    armed = 1'b1;
    CH_Trig = 1'b0;
    CH_Hff5 = 1'b0;
    CH_Lff5 = 1'b0;

    @ (posedge clk); 
    rst_n = 1'b1;
    
    //Test 1: Low Level trigger

    @ (posedge clk);
    CH_TrigCfg = 5'b00010;
    @ (posedge clk);
    if (CH_Trig == 0) begin
        $display("[failed]: Test 1a failed because CH_trig was not asserted");
        $stop();
    end else $display("[pass]: Test 1a passed");

    @ (posedge clk);
    CH_Lff5 = 1'b1;
    @ (posedge clk);
    if (CH_Trig == 1) begin
        $display("[failed]: Test 1b failed because CH_trig was not deasserted");
        $stop();
    end else $display("[pass]: Test 1b passed");

    //Test 2: High Level trigger

    @ (posedge clk);
    CH_TrigCfg = 5'b00100;
    @ (posedge clk);
    if (CH_Trig == 1) begin
        $display("[failed]: Test 2a failed because CH_trig was incorrectly asserted");
        $stop();
    end else $display("[pass]: Test 2a passed");

    @ (posedge clk);
    CH_Hff5 = 1'b1;
    @ (posedge clk);
    if (CH_Trig == 0) begin
        $display("[failed]: Test 2b failed because CH_trig was not asserted");
        $stop();
    end else $display("[pass]: Test 2b passed");

    //Test 3: NegEdge trigger

    @ (posedge clk); 
    CH_TrigCfg = 5'b01000;
    CH_Lff5 = 1'b1;
    @ (posedge clk);
    armed = 1'b0;
    @ (posedge clk);
    armed = 1'b1;
    #6 CH_Lff5 = 1'b0;
    @ (posedge clk);
    if (CH_Trig == 0) begin
        $display("[failed]: Test 3 failed because CH_trig was not asserted");
        $stop();
    end else $display("[pass]: Test 3 passed");

    //Test 4: PosEdge trigger
    @ (posedge clk); 
    CH_TrigCfg = 5'b10000;
    CH_Hff5 = 1'b0;
    @ (posedge clk);
    armed = 1'b0;
    @ (posedge clk);
    armed = 1'b1;
    #6 CH_Hff5 = 1'b1;
    @ (posedge clk);
    if (CH_Trig == 0) begin
        $display("[failed]: Test 3 failed because CH_trig was not asserted");
        $stop();
    end else $display("[pass]: Test 3 passed");

    //Test 5: Don't Care override
    @ (posedge clk);
    CH_TrigCfg = 5'b00010;
    CH_Lff5 = 1'b1;
    @ (posedge clk);
    $display("test 5 pt 1 done");

    @ (posedge clk);
    CH_TrigCfg -= 1;
    @ (posedge clk);
    if (CH_Trig !== 1) begin
        $display("[failed]: Test 5 failed because the don't care override failed to assert CH_trig");
        $stop();
    end else $display("[pass]: Test 5 passed");

end
always #4 clk = ~clk;
endmodule