module UART_prot(clk, rst_n, RX, baud_cnt, mask, match, UARTtrig);

input RX, clk, rst_n;
input [15:0] baud_cnt;
input [7:0] mask, match;

output logic UARTtrig;

logic [7:0] uart;

always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        uart <= 0;
    end
    else begin
        uart = {{uart[6:0]}, RX};
    end

end
always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n)
        UARTtrig <= 0;
    else begin
        UARTtrig <= ((uart | mask) == (mask | match));
    end
end




endmodule