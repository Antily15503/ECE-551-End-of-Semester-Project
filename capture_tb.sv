module capture_tb();

logic clk, rst_n, wrt_smpl, run, capture_done, triggered, we, set_capture_done, armed;
logic [8:0] waddr, raddr, trig_pos;
logic [7:0] wdata, rdata;


RAMqueue iRAMQueue(.waddr(waddr), .wdata(wdata), .we(we), .raddr(raddr), .rdata(rdata), .clk(clk));

capture iDUT(.clk(clk), .rst_n(rst_n), .wrt_smpl(wrt_smpl), .run(run), .capture_done(capture_done), .triggered(triggered), .trig_pos(trig_pos),
               .we(we), .waddr(waddr), .set_capture_done(set_capture_done), .armed(armed));

initial begin
    clk <= 0;
    wdata = 0;
    rst_n = 1;
    run = 0;
    trig_pos = 9'd2;
    wrt_smpl = 1;
    triggered = 0;
    #5 rst_n = 0;
    #5 rst_n = 1;
    #5 run = 1;

    if(waddr != 0) begin
        $display("ERR: waddr is not 0");
        $stop;
    end

    @(posedge armed)
    if(waddr!= 9'h17d) begin
        $display("ERR: waddr + trig_pos (40) should be 382 when armed is set, is actually :%h", waddr);
        $stop;
    end

    #50;

    triggered = 1;
    @(posedge set_capture_done)
    #5 capture_done = 1;
    if(waddr!=9'h17f) begin
        $display("ERR: capture done asserted before the required samples (trig_cnt = 2) completed");
        $stop;
    end
    if(armed!=0) begin
        $display("ERR: armed was not set to 0 after capture completed");
        $stop;
    end


    #50 capture_done = 0;

    $display("YAHOO!!!! ALL TESTS PASSED");
    $stop;

end



always begin
    #50 clk = ~clk;
    wdata = wdata+1;
end





endmodule
