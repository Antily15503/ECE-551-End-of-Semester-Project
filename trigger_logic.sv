module trigger_logic(CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, 
                    armed, set_capture_done, clk, rst_n, triggered, protTrig);

input CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, armed, set_capture_done, clk, rst_n, protTrig;
output reg triggered;


always_ff @(posedge clk, posedge set_capture_done, negedge rst_n) begin
    if(CH1Trig && CH2Trig && CH3Trig && CH4Trig && CH5Trig && rst_n && armed && ~set_capture_done) begin
        triggered <= 1;
    end
    else if((triggered == 1) && rst_n && ~set_capture_done) begin
        triggered <= 1;
    end
    else begin
        triggered <= 0;
    end
end

endmodule;