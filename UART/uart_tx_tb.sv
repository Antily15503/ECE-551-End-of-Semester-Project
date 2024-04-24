module UART_tx_tb();
	logic clk, rst_n, trmt;
	logic[7:0] tx_data;
	wire tx_done, TX;

	UART_tx DUT(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX));
	

	initial begin
        rst_n = 1;
        #10
		clk = 0;
		rst_n = 0;
		trmt = 0;
		tx_data = 0;
		#10;
		rst_n = 1;
		tx_data = 8'b10101010;
		#10;
		trmt = 1;
		#10
		trmt = 0;
		@(posedge tx_done)
        #50;
		tx_data = 8'b11001100;
		trmt = 1;
		#10;
		trmt = 0;
		@(posedge tx_done)
        #50;
		tx_data = 8'b10001000;
		trmt = 1;
		#10;
		trmt = 0;
	    @(posedge tx_done)
        #50;
		$finish;
	end
    always begin
		#5 clk = ~clk;
    end
		
endmodule