module RAMqueue(waddr, wdata, we, raddr, rdata, clk);

parameter ENTRIES = 384;
parameter LOG2 = 9;

input clk, we;
input[LOG2-1:0] waddr, raddr;
input [7:0] wdata;
output reg [7:0] rdata;

logic [LOG2-1:0] waddr_new, raddr_new;

reg [7:0] memory[0:ENTRIES-1];

// synposys translate_off
// synthesis translate_off
always_ff @(posedge clk)begin
    if(waddr > ENTRIES-1) begin
        waddr_new <= waddr - ENTRIES-1;
    end
    else
        waddr_new <= waddr;
    if(raddr > ENTRIES-1) begin
        raddr_new <= raddr - ENTRIES-1;
    end
    else 
        raddr_new <= raddr;
end



always_ff @(posedge clk) begin
    if (we) begin
        memory[waddr_new] <= wdata;
    end
    rdata <= memory[raddr_new];
end
// synposys translate_on
// synthesis translate_on
endmodule

