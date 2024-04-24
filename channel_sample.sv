<<<<<<< HEAD
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

=======
module channel_sample(smpl_clk, CHxL, CHxH, clk, smpl, CHxLff5, CHxHff5);
input smpl_clk, CHxL, CHxH, clk;
output reg [7:0] smpl;

output reg CHxLff5, CHxHff5;

logic CHxL1, CHxH1, CHxL2, CHxH2, CHxL3, CHxH3, CHxL4, CHxH4;

always @(negedge smpl_clk)begin
    CHxL1 <= CHxL;
    CHxH1 <= CHxH;
end

always @(negedge smpl_clk)begin
    CHxL2 <= CHxL1;
    CHxH2 <= CHxH1;
end

always @(negedge smpl_clk)begin
    CHxL3 <= CHxL2;
    CHxH3 <= CHxH2;
end

always @(negedge smpl_clk)begin
    CHxL4 <= CHxL3;
    CHxH4 <= CHxH3;
end

always @(negedge smpl_clk)begin
    CHxLff5 <= CHxL4;
    CHxHff5 <= CHxH4;
end

always @(posedge clk)
    smpl <= {CHxH2, CHxL2, CHxH3, CHxL3, CHxH4, CHxL4, CHxHff5, CHxLff5};

>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule