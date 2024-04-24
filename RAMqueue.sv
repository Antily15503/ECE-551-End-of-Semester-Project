<<<<<<< HEAD
module RAMqueue(waddr, wdata, we, raddr, rdata, clk);

parameter ENTRIES = 384;
parameter LOG2 = 9;

input clk, we;
input[LOG2-1:0] waddr, raddr;
input [7:0] wdata;
output reg [7:0] rdata;

reg [7:0] memory[ENTRIES-1:0];

always_ff @(posedge clk) begin
    if (we) begin
        memory[waddr] <= wdata;
    end
    rdata <= memory[raddr];
end

endmodule

=======
module RAMqueue(waddr, wdata, we, raddr, rdata, clk);

parameter ENTRIES = 384;
parameter LOG2 = 9;

input clk, we;
input[LOG2-1:0] waddr, raddr;
input [7:0] wdata;
output reg [7:0] rdata;

reg [7:0] memory[ENTRIES-1:0];

always_ff @(posedge clk) begin
    if (we) begin
        memory[waddr] <= wdata;
    end
    rdata <= memory[raddr];
end

endmodule

>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
