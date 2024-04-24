module RAMqueue_tb();

reg [8:0] waddr, raddr;
reg [7:0] wdata;
reg clk, we;
wire[7:0] rdata;

RAMqueue iDUT(.waddr(waddr), .wdata(wdata), .we(we), .raddr(raddr), .rdata(rdata), .clk(clk));
initial begin
    clk = 0;
   we = 0;
   @(posedge clk);
   #3 waddr = 9'h123;
   wdata = 8'hAB;
   we = 1;
   raddr = 9'h123;

   @(posedge clk);
   #3 waddr = 9'h124;
   wdata = 8'hCD;

   @(posedge clk);
   #3 wdata = 8'hEF;
   we = 0;
   raddr = 9'h124;

   @(posedge clk);
   if(rdata!=8'hAB) begin
        $display("ERROR: rdata should be 8'hAB, is instead %h", rdata);
   end
   #3 waddr = 9'h125;
   we = 1;

   @(posedge clk);
   if(rdata!=8'hCD) begin
        $display("ERROR: rdata should be 8'hCD, is instead %h", rdata);
   end
   #3 waddr = 9'h126;
   wdata = 8'hXX;
   we = 0;
   raddr = 9'h125;

   #18;
   if(rdata!=8'hEF) begin
        $display("ERROR: rdata should be 8'hEF, is instead %h", rdata);
   end
   $finish;
end

always begin
    #6 clk <= ~clk;
end

endmodule