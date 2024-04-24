module channel_sample(smpl_clk, CH_L, CH_H, clk, smpl, CH_Lff5, CH_Hff5);
input smpl_clk, CH_L, CH_H, clk;
output reg [7:0] smpl;

output reg CH_Lff5, CH_Hff5;

logic CH_L1, CH_H1, CH_L2, CH_H2, CH_L3, CH_H3, CH_L4, CH_H4;

always @(negedge smpl_clk)begin
    CH_L1 <= CH_L;
    CH_H1 <= CH_H;
end

always @(negedge smpl_clk)begin
    CH_L2 <= CH_L1;
    CH_H2 <= CH_H1;
end

always @(negedge smpl_clk)begin
    CH_L3 <= CH_L2;
    CH_H3 <= CH_H2;
end

always @(negedge smpl_clk)begin
    CH_L4 <= CH_L3;
    CH_H4 <= CH_H3;
end

always @(negedge smpl_clk)begin
    CH_Lff5 <= CH_L4;
    CH_Hff5 <= CH_H4;
end

always @(posedge clk)
    smpl <= {CH_H2, CH_L2, CH_H3, CH_L3, CH_H4, CH_L4, CH_Hff5, CH_Lff5};

endmodule