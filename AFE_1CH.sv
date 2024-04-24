module AFE_1CH(clk400MHz, CH_L, CH_H);
input clk400MHz;

output CH_L, CH_H;
logic [12:0] ptr;
logic [7:0] CHmem[8191:0];
logic [7:0] VIL, VIH, sigval;

initial begin
    ptr = 12'h000;
    $readmemh("CHmem.txt",CHmem);
    VIL = 8'h55;
    VIH = 8'hAA;
end

always @(posedge clk400MHz)begin
    if(ptr == 12'hFFF)
        ptr <= 12'h000;
    else
        ptr <= ptr+1;   
end
assign sigval = CHmem[ptr];
assign CH_L = (sigval < VIL) ? 1'b0 : 1'b1;
assign CH_H = (sigval < VIH) ? 1'b1 : 1'b0;



endmodule