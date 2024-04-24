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

endmodule