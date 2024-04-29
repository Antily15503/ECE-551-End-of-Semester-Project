module UART_rx_cfg_bd(clk, rst_n, RX, rdy, rx_data, clr_rdy, baud, match, mask, UARTtrig);
	input clk, rst_n, RX, clr_rdy;
    input [7:0] match, mask;
    output UARTtrig;
    input[15:0] baud;
	output rdy;
	output[7:0] rx_data;
	wire receiving, shift, busy, clr_busy, start, set_ready;
	wire[3:0] bit_cnt;
assign UARTtrig = (((rx_data | mask) == (match | mask)) ? 1 : 0) & rdy;
	
	UARTRxSm statemachine(.clk(clk), .rst_n(rst_n), .shift(shift), .receiving(receiving), 
                    .busy(busy), .clr_busy(clr_busy), .start(start), .bit_cnt(bit_cnt), .set_ready(set_ready));
	UARTRxDpCfgBd datapath(.clk(clk), .rst_n(rst_n), .start(start), .receiving(receiving),
						.shift(shift), .rx_data(rx_data), .RX(RX), .clr_busy(clr_busy), .busy(busy), 
						.bit_cnt(bit_cnt), .set_ready(set_ready), .clr_rdy(clr_rdy), .ready(rdy), .baudCntA(baud));
endmodule

module UARTRxDpCfgBd(clk, rst_n, start, receiving, shift, rx_data,
				RX, clr_busy, busy, bit_cnt, set_ready, clr_rdy, ready, baudCntA);

	input clk, rst_n, start, receiving, RX, clr_busy, set_ready, clr_rdy;
    input[15:0] baudCntA;
	output logic shift, busy, ready;
	output logic[7:0] rx_data;
	output logic[3:0] bit_cnt;
	logic[9:0] shift_reg;
	logic[15:0] baud_cnt;
	logic rx_in1, rx_in2;
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			baud_cnt <= '0;
		end
		else begin
			casex({shift, receiving})
				2'b0_0: baud_cnt <= baud_cnt;
				2'b0_1: baud_cnt <= baud_cnt + 1;
				2'b1_x: baud_cnt <= 0;
			endcase
		end
	end
	
	always_ff @(posedge clk) begin
			 //set busy
            if(!rx_in1 & rx_in2) begin
                busy <= 1;
            end
            else if(clr_busy) begin
                busy <= 0;
            end
            else begin
                busy <= busy;
            end
	end

	always_ff @(posedge clk) begin
    //set ready
            if(clr_rdy || start) begin
                ready <= 0;
            end
            else if(set_ready) begin
                ready <= 1;
            end
            else begin
                ready <= ready;
            end

	end

	always_ff@(posedge clk) begin
			rx_in1 <= RX;
			rx_in2 <= rx_in1;
	end

	always_ff@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			shift_reg <= 10'd0;
		end
		else begin
			casex(shift)
				1'b0: shift_reg <= shift_reg;
				1'b1: shift_reg <= {RX, shift_reg[9:1]};
			endcase
		end
	end

	always_ff@(posedge clk) begin
		if(!rst_n)begin
			rx_data <= '0;
		end
		casex(bit_cnt)
			9: rx_data <= shift_reg[8:1];
			default: rx_data <= rx_data;
		endcase

	end
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			bit_cnt <= '0;
        end
		else begin
			casex({start, shift})
				2'b0_0: bit_cnt <= bit_cnt;
				2'b0_1: bit_cnt <= bit_cnt + 1;
				default: bit_cnt <= 0;
			endcase
		end
	end

	always_comb begin
		// Wait for 1.5 cycles
		if(bit_cnt == 0)
			if(baud_cnt == baudCntA * 1.5)
				shift = 1;
			else	
				shift = 0;
		// Wait for 1 cycle
		else
			if(baud_cnt == baudCntA)
				shift = 1;
			else
				shift = 0;
	end	
	
endmodule




















