<<<<<<< HEAD
module trigger_logic_tb();
logic CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, armed, set_capture_done, clk, rst_n;
wire triggered;

trigger_logic iDut(.CH1Trig(CH1Trig),.CH2Trig(CH2Trig), .CH3Trig(CH3Trig), .CH4Trig(CH4Trig), .CH5Trig(CH5Trig), 
                    .armed(armed), .set_capture_done(set_capture_done), .clk(clk), .rst_n(rst_n), .triggered(triggered));

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    rst_n = 1;
    @(posedge clk);

    rst_n = 0;

    @(posedge clk);
    armed = 0;
    rst_n = 1;
    set_capture_done = 0;
    CH1Trig = 1;
    CH2Trig = 1;
    CH3Trig = 1;
    CH4Trig = 1;
    CH5Trig = 1;
    if(triggered == 1) begin
        $display("ERROR: triggered high when armed and s_c_d are low");
        $stop;
    end

    @(posedge clk);
    CH1Trig = 0;
    armed = 1;
    @(posedge clk);
    if(triggered == 1) begin
        $display("ERROR: triggered high when ch1 is low");
        $stop;
    end

    @(posedge clk);
    CH1Trig = 1;
    @(posedge clk);
    @(posedge clk);
    if(triggered == 0) begin
        $display("ERROR: triggered low when armed and all channels are high");
        $stop;
    end

    @(posedge clk);
    CH1Trig = 0;
    armed = 0;
    @(posedge clk);
    
    if(triggered == 0) begin
        $display("ERROR: triggered should only be lowered by s_c_d");
        $stop;
    end

    @(posedge clk);
    set_capture_done = 1;
    @(posedge clk);
    if(triggered == 1) begin
        $display("ERROR: triggered should be low when s_c_d is high");
        $stop;
    end

    $display("YAHOO! All tests passed!");
    $finish;

end


=======
module trigger_logic_tb();
logic CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, armed, set_capture_done, clk, rst_n;
wire triggered;

trigger_logic iDut(.CH1Trig(CH1Trig),.CH2Trig(CH2Trig), .CH3Trig(CH3Trig), .CH4Trig(CH4Trig), .CH5Trig(CH5Trig), 
                    .armed(armed), .set_capture_done(set_capture_done), .clk(clk), .rst_n(rst_n), .triggered(triggered));

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    rst_n = 1;
    @(posedge clk);

    rst_n = 0;

    @(posedge clk);
    armed = 0;
    rst_n = 1;
    set_capture_done = 0;
    CH1Trig = 1;
    CH2Trig = 1;
    CH3Trig = 1;
    CH4Trig = 1;
    CH5Trig = 1;
    if(triggered == 1) begin
        $display("ERROR: triggered high when armed and s_c_d are low");
        $stop;
    end

    @(posedge clk);
    CH1Trig = 0;
    armed = 1;
    @(posedge clk);
    if(triggered == 1) begin
        $display("ERROR: triggered high when ch1 is low");
        $stop;
    end

    @(posedge clk);
    CH1Trig = 1;
    @(posedge clk);
    @(posedge clk);
    if(triggered == 0) begin
        $display("ERROR: triggered low when armed and all channels are high");
        $stop;
    end

    @(posedge clk);
    CH1Trig = 0;
    armed = 0;
    @(posedge clk);
    
    if(triggered == 0) begin
        $display("ERROR: triggered should only be lowered by s_c_d");
        $stop;
    end

    @(posedge clk);
    set_capture_done = 1;
    @(posedge clk);
    if(triggered == 1) begin
        $display("ERROR: triggered should be low when s_c_d is high");
        $stop;
    end

    $display("YAHOO! All tests passed!");
    $finish;

end


>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule