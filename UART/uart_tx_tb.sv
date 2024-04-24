<<<<<<< HEAD
module UART_tx_tb();
	logic clk, rst_n, trmt;
	logic[7:0] tx_data, mask, match;
	wire tx_done, TX, UARTtrig;
	logic [15:0] baud_cnt;


	UART_tx_cfg_bd DUT(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX), .baud_cnt(baud_cnt));
	UART_prot prot(.clk(clk), .rst_n(rst_n), .RX(TX), .baud_cnt(baud_cnt), .mask(mask), .match(match), .UARTtrig(UARTtrig));

	initial begin
        rst_n = 1;
        #10
		clk = 0;
		rst_n = 0;
		trmt = 0;
		baud_cnt = 16'h1010;
		tx_data = 0;
		#10;
		rst_n = 1;
		tx_data = 8'b10101010;
		match = 8'b10101010;
		mask = 8'b00000000;
		#10;
		trmt = 1;
		#10
		trmt = 0;
		@(posedge tx_done)
        #50;
		tx_data = 8'b11001100;
		match = 8'b11000000;
		mask = 8'b00001111;
		trmt = 1;
		#10;
		trmt = 0;
		@(posedge tx_done)
        #50;
		tx_data = 8'b10001000;
		match = 8'b10010001;
		mask = 8'b00000000;
		trmt = 1;
		#10;
		trmt = 0;
	    @(posedge tx_done)
        #50;

		baud_cnt = 16'h8888;
		#10
		clk = 0;
		rst_n = 0;
		trmt = 0;
		tx_data = 0;
		#10;
		rst_n = 1;
		tx_data = 8'b10101010;
		match = 8'b10101010;
		mask = 8'b00000000;
		#10;
		trmt = 1;
		#10
		trmt = 0;
		@(posedge tx_done)
        #50;
		tx_data = 8'b11001100;
		match = 8'b11000000;
		mask = 8'b00001111;
		trmt = 1;
		#10;
		trmt = 0;
		@(posedge tx_done)
        #50;
		tx_data = 8'b10001000;
		match = 8'b10010001;
		mask = 8'b00000000;
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
		
=======
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
		
>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule