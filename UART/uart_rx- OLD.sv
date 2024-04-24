module UART_rx(clk, rst_n, RX, rdy, rx_data, clr_rdy, baud_cnt, match, mask, UARTtrig);
	input clk, rst_n, RX, clr_rdy;
	input [15:0] baud_cnt;
	input [7:0] mask, match;
	output rdy, UARTtrig;
	output[7:0] rx_data;
	wire receiving, shift, busy, clr_busy, start, set_rdy;
	wire[3:0] bit_cnt;
	
	// State machine instance
	UARTRxSm iSM(.clk(clk), .rst_n(rst_n), .shift(shift), .receiving(receiving),
				.busy(busy), .clr_busy(clr_busy), .start(start), .bit_cnt(bit_cnt), .set_rdy(set_rdy));
	// Datapath instance
	UARTRxDp iDP(.clk(clk), .rst_n(rst_n), .start(start), .receiving(receiving),
							.shift(shift), .rx_data(rx_data), .RX(RX), .clr_busy(clr_busy), .busy(busy), 
							.bit_cnt(bit_cnt), .set_rdy(set_rdy), .rdy(rdy), .clr_rdy(clr_rdy),
							.baud_cntA(baud_cnt));
	
	assign UARTtrig = (((rx_data | mask) == (match | mask)) ? 1 : 0) & rdy;


endmodule
module UARTRxDp(clk, rst_n, start, receiving, shift, rx_data,
						RX, clr_busy, busy, bit_cnt, set_rdy, clr_rdy, rdy, baud_cntA);


	input clk, rst_n, start, receiving, RX, clr_busy, set_rdy, clr_rdy;
	input[15:0] baud_cntA;
	output logic shift, busy, rdy;
	output logic[7:0] rx_data;
	output logic[3:0] bit_cnt;
	logic[9:0] shift_reg;
	logic[15:0] baud_cnt;
	logic rx_sync_1, rx_sync_2;
	
	// bit_cnt logic
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			bit_cnt <= 0;
			baud_cnt <= 0;
			shift_reg <= 0;
			rx_data <= 0;
			busy <= 0;
			rx_sync_1 <= 0;
			rx_sync_2 <= 0;
			rdy <= 0;
		end
		else begin
			rx_sync_1 <= RX;
			rx_sync_2 <= rx_sync_1;

			//set rdy
            if(clr_rdy) begin
                rdy <= 0;
            end
            else if(set_rdy) begin
                rdy <= 1;
            end
            else begin
                rdy <= rdy;
            end
			//set busy
            if(!rx_sync_1 & rx_sync_2) begin
                busy <= 1;
            end
            else if(clr_busy) begin
                busy <= 0;
            end
            else begin
                busy <= busy;
            end
			casex({start, shift})
				2'b00: bit_cnt <= bit_cnt;
				2'b01: bit_cnt <= bit_cnt + 1;
				2'b1x: bit_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
			casex({shift, receiving})
				2'b00: begin 
					baud_cnt <= baud_cnt; 
					shift_reg <= shift_reg; 
					end
				2'b01: begin 
					baud_cnt <= baud_cnt + 1; 
					shift_reg <= shift_reg;
					end
				2'b1x: begin 
					baud_cnt <= 0; 
					shift_reg <= {RX, shift_reg[9:1]};
					end
			endcase
			casex(bit_cnt)
				9: rx_data <= shift_reg[8:1];
				default: rx_data <= rx_data;
			endcase
		end
	end
	
	always_comb begin
		// Wait for 1.5 cycles
			if(baud_cnt == baud_cntA)
				shift = 1;
			else
				shift = 0;
	end	

	
endmodule
module UARTRxSm(clk, rst_n, shift, receiving, busy, clr_busy, start, bit_cnt, set_rdy);
	input clk, rst_n, shift, busy;
	input[3:0] bit_cnt;
	output reg receiving, clr_busy, start, set_rdy; 
	typedef enum reg[1:0] {IDLE, WAIT, SHIFT} state_t;
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
		set_rdy = 0;
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
				if(bit_cnt < 10) begin
					nxt_state = WAIT;
					receiving = 1;
				end
				else begin
					nxt_state = IDLE;
					set_rdy = 1;
					clr_busy = 1;
				end
			end
		endcase
	end
	
endmodule




















