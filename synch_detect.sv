module synch_detect(asynch_sig_in, clk, rst_n, rise_edge);
input asynch_sig_in, clk, rst_n;
output rise_edge;

wire dffOut1, dffOut2, notOut, andOut;

dff dff0(.D(asynch_sig_in), .clk(clk), .Q(dffOut1), .PRN(rst_n));
dff dff1(.D(dffOut1), .clk(clk), .Q(dffOut2), .PRN(rst_n));

not (notOut, dffOut2);
and (andOut, notOut, asynch_sig_in);
dff dff2(.D(andOut), .clk(clk), .Q(rise_edge), .PRN(rst_n));

endmodule
