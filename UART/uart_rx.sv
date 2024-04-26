module UART_rx(clk, rst_n, RX, rdy, rx_data, clr_rdy);
	input clk, rst_n, RX, clr_rdy;
	output rdy;
	output[7:0] rx_data;
	wire receiving, shift, busy, clr_busy, start, set_ready;
	wire[3:0] bit_cnt;
	
	UARTRxSm statemachine(.clk(clk), .rst_n(rst_n), .shift(shift), .receiving(receiving), 
                    .busy(busy), .clr_busy(clr_busy), .start(start), .bit_cnt(bit_cnt), .set_ready(set_ready));
	UARTRxDp datapath(.clk(clk), .rst_n(rst_n), .start(start), .receiving(receiving),
						.shift(shift), .rx_data(rx_data), .RX(RX), .clr_busy(clr_busy), .busy(busy), 
						.bit_cnt(bit_cnt), .set_ready(set_ready), .clr_rdy(clr_rdy), .ready(rdy));
	
endmodule

module UARTRxSm(clk, rst_n, shift, receiving, busy, clr_busy, start, bit_cnt, set_ready);
	input clk, rst_n, shift, busy;
	input[3:0] bit_cnt;
	output logic receiving, clr_busy, start, set_ready; 
	typedef enum logic[1:0] {IDLE, WAIT, SHIFT} state_t;
	state_t state, nxt_state;
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	always_comb begin
		nxt_state = IDLE;
		receiving = 0;
		clr_busy = 0;
		start = 0;
		set_ready = 0;
		case(state)
			IDLE: begin
				if(busy) begin
					nxt_state = WAIT;
					start = 1;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
				end
			end
			WAIT: begin
				if(shift) begin
					nxt_state = SHIFT;
				end
				else begin
					nxt_state = WAIT;
					receiving = 1;
				end
			end
			SHIFT: begin
				if(bit_cnt < 9) begin
					nxt_state = WAIT;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
					set_ready = 1;
					clr_busy = 1;
				end
			end
		endcase
	end
	
endmodule

module UARTRxDp(clk, rst_n, start, receiving, shift, rx_data,
				RX, clr_busy, busy, bit_cnt, set_ready, clr_rdy, ready);

	input clk, rst_n, start, receiving, RX, clr_busy, set_ready, clr_rdy;
	output logic shift, busy, ready;
	output logic[7:0] rx_data;
	output logic[3:0] bit_cnt;
	logic[9:0] shift_reg;
	logic[6:0] baud_cnt;
	logic rx_in1, rx_in2;
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			bit_cnt <= '0;
            baud_cnt = '0;
            shift_reg = 9'd0;
            rx_data <= '0;
            rx_in1 <= '0;
			rx_in2 <= '0;
        end
		else
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

            rx_in1 <= RX;
			rx_in2 <= rx_in1;

			casex(shift)
				1'b0: shift_reg <= shift_reg;
				1'b1: shift_reg <= {RX, shift_reg[9:1]};
			endcase

            casex(bit_cnt)
				9: rx_data <= shift_reg[8:1];
				default: rx_data <= rx_data;
			endcase

            casex({shift, receiving})
				2'b0_0: baud_cnt <= baud_cnt;
				2'b0_1: baud_cnt <= baud_cnt + 1;
				2'b1_x: baud_cnt <= 0;
			endcase

            casex({start, shift})
				2'b0_0: bit_cnt <= bit_cnt;
				2'b0_1: bit_cnt <= bit_cnt + 1;
				2'b1_x: bit_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
	end

	always_comb begin
		// Wait for 1.5 cycles
		if(bit_cnt == 0)
			if(baud_cnt == 30)
				shift = 1;
			else	
				shift = 0;
		// Wait for 1 cycle
		else
			if(baud_cnt == 20)
				shift = 1;
			else
				shift = 0;
	end	
	
endmodule




















