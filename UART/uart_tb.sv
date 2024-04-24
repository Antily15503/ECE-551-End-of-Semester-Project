<<<<<<< HEAD
module uart_rx_tb();
//tx signals
logic clk, rst_n, trmt;
logic[7:0] tx_data;
wire tx_done, TX;

//rx signals
wire[7:0] rx_data;
logic clr_rdy;
wire rdy;

UART_tx tx(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX));
UART_rx rx(.clk(clk), .rst_n(rst_n), .RX(TX), .rdy(rdy), .rx_data(rx_data), .clr_rdy(clr_rdy));


initial begin
    rst_n = 1;
    clr_rdy = 1;
    #10;
    clk = 0;
    rst_n = 0;
    clr_rdy = 0;
    trmt = 0;
    tx_data = 0;
    #10;
    rst_n = 1;
    tx_data = 8'b10101010;
    #10;
    trmt = 1;
    #10
    trmt = 0;
    @(posedge tx_done);
    if(tx_data != rx_data) begin
        $display("ERROR: RX DATA DOES NOT MATCH. TX: %h, RX: %h", tx_data, rx_data);
        $stop;
    end
    #50;
    clr_rdy = 1;
    #10;
    clr_rdy = 0;

    #10;
    tx_data = 8'b11001100;
    trmt = 1;
    #10
    trmt = 0;
    @(posedge tx_done);
    if(tx_data != rx_data) begin
        $display("ERROR: RX DATA DOES NOT MATCH. TX: %h, RX: %h", tx_data, rx_data);
        $stop;
    end
    #50;
    clr_rdy = 1;
    #10;
    clr_rdy = 0;
    #10;
    tx_data = 8'b10001000;
    trmt = 1;
    #10
    trmt = 0;
    @(posedge tx_done);
    if(tx_data != rx_data) begin
        $display("ERROR: RX DATA DOES NOT MATCH. TX: %h, RX: %h", tx_data, rx_data);
        $stop;
    end
    clr_rdy = 1;
    #10;
    clr_rdy = 0;

    $display("YAHOO! All tests passed!!!");
    $finish;



end


always begin
    #5 clk = ~clk;
end

=======
module uart_rx_tb();
//tx signals
logic clk, rst_n, trmt;
logic[7:0] tx_data;
wire tx_done, TX;

//rx signals
wire[7:0] rx_data;
logic clr_rdy;
wire rdy;

UART_tx tx(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX));
UART_rx rx(.clk(clk), .rst_n(rst_n), .RX(TX), .rdy(rdy), .rx_data(rx_data), .clr_rdy(clr_rdy));


initial begin
    rst_n = 1;
    clr_rdy = 1;
    #10;
    clk = 0;
    rst_n = 0;
    clr_rdy = 0;
    trmt = 0;
    tx_data = 0;
    #10;
    rst_n = 1;
    tx_data = 8'b10101010;
    #10;
    trmt = 1;
    #10
    trmt = 0;
    @(posedge tx_done);
    if(tx_data != rx_data) begin
        $display("ERROR: RX DATA DOES NOT MATCH. TX: %h, RX: %h", tx_data, rx_data);
        $stop;
    end
    #50;
    clr_rdy = 1;
    #10;
    clr_rdy = 0;

    #10;
    tx_data = 8'b11001100;
    trmt = 1;
    #10
    trmt = 0;
    @(posedge tx_done);
    if(tx_data != rx_data) begin
        $display("ERROR: RX DATA DOES NOT MATCH. TX: %h, RX: %h", tx_data, rx_data);
        $stop;
    end
    #50;
    clr_rdy = 1;
    #10;
    clr_rdy = 0;
    #10;
    tx_data = 8'b10001000;
    trmt = 1;
    #10
    trmt = 0;
    @(posedge tx_done);
    if(tx_data != rx_data) begin
        $display("ERROR: RX DATA DOES NOT MATCH. TX: %h, RX: %h", tx_data, rx_data);
        $stop;
    end
    clr_rdy = 1;
    #10;
    clr_rdy = 0;

    $display("YAHOO! All tests passed!!!");
    $finish;



end


always begin
    #5 clk = ~clk;
end

>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule