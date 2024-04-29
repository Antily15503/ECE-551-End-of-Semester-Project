module UART_prot(clk, rst_n, RX, baud_cnt, mask, match, UARTtrig);

input RX, clk, rst_n;
input [15:0] baud_cnt;
input [7:0] mask, match;

output logic UARTtrig;

UART_rx_cfg_bd iRxCfgBd(.clk(clk), .rst_n(rst_n), .clr_rdy(1'b0), .rdy(), .RX(RX), .rx_data(), .baud(baud_cnt), .match(match), .mask(mask), .UARTtrig(UARTtrig));





endmodule


