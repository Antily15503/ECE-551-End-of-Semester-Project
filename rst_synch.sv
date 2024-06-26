module rst_synch(RST_n, rst_n, clk);
input RST_n, clk;
output logic rst_n;

logic rst;

always_ff @(negedge clk, negedge RST_n) begin
    if(!RST_n) begin
        rst <= 1'b0;
        rst_n <= 1'b0;
    end
    else begin
        rst <= 1'b1;
        rst_n <= rst;
    end
end

endmodule