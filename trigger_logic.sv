module trigger_logic(CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, 
                    armed, set_capture_done, clk, rst_n, triggered, protTrig);

input CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, armed, set_capture_done, clk, rst_n, protTrig;
output reg triggered;


always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        triggered <= 0;
    end
    else if(CH1Trig && CH2Trig && CH3Trig && CH4Trig && CH5Trig && armed && ~set_capture_done) begin
        triggered <= 1;
    end
    else if((triggered == 1) && ~set_capture_done) begin
        triggered <= 1;
    end
    else begin
        triggered <= 0;
    end
end

endmodule;