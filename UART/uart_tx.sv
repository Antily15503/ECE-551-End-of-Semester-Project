module UART_tx(clk, rst_n, trmt, tx_data, tx_done, TX);
	input clk, rst_n, trmt;
	input[7:0] tx_data;
	output TX, tx_done;
	wire load, transmit, shift, set_done, clr_done;
	wire[3:0] bit_cnt;
	
	UARTTxSm SM(.clk(clk), .rst_n(rst_n), .trmt(trmt), .bit_cnt(bit_cnt), .load(load), .transmit(transmit), .shift(shift), .set_done(set_done), .clr_done(clr_done));

	UARTTxData DP(.clk(clk), .rst_n(rst_n), .TX(TX), .tx_data(tx_data), .tx_done(tx_done), .load(load), .transmit(transmit), .shift(shift), 
				.bit_cnt(bit_cnt), .set_done(set_done), .clr_done(clr_done));

endmodule

module UARTTxSm(clk, rst_n, trmt, bit_cnt, load, transmit, shift, set_done, clr_done);
	input clk, rst_n, trmt, shift;
	input[3:0] bit_cnt;
	output load, transmit, set_done, clr_done;
    
	typedef enum logic[1:0] {IDLE, TRANSMIT, SHIFT} state_t;
	state_t state, nxt_state;
	logic load, transmit, set_done, clr_done;
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) begin
			state <= IDLE;
        end
		else begin
			state <= nxt_state;
        end
	
	always_comb begin
		set_done = 1'b0;
		load = 1'b0;
		clr_done = 1'b0;
		transmit = 1'b0;
		nxt_state = IDLE;
		case(state)
            SHIFT: begin
				if (bit_cnt < 10) begin
					transmit = 1'b1;
					nxt_state = TRANSMIT;
				end
				else begin
					set_done = 1'b1;
					nxt_state = IDLE;
				end
			end
            TRANSMIT: begin
				if(shift)begin
					nxt_state = SHIFT;
					if (bit_cnt < 9)
						transmit = 1'b1;
				end
				else begin
					nxt_state = TRANSMIT;
					transmit = 1'b1;
				end
			end
            IDLE: begin
				if(trmt)begin
					transmit = 1'b1;
					clr_done = 1'b1;
					nxt_state = TRANSMIT;
					load = 1'b1;
				end
				else begin
					nxt_state = IDLE;
                end
			end
		endcase
	end
	
endmodule
module UARTTxData(clk, rst_n, TX, tx_data, tx_done, load, transmit, shift, 
				    bit_cnt, set_done, clr_done);

	input clk, rst_n, load, set_done, clr_done, transmit;
	input[7:0] tx_data;

	output TX, shift;
	output logic tx_done;
	output logic [3:0] bit_cnt;
	logic [15:0] baud_cnt;
	logic [9:0] tx_shift_reg;
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			baud_cnt <= 0;
			tx_shift_reg <= 9'h1ff;
			bit_cnt <= 0;
            tx_done <= 0;
        end
		else begin
			casex ({shift, transmit})
				2'b00: baud_cnt <= baud_cnt;
				2'b01: baud_cnt <= baud_cnt + 1;
				2'b1x: baud_cnt <= 0;
				default: bit_cnt <= 0;
			endcase
            casex ({load, shift})
				2'b00: begin 
                    bit_cnt <= bit_cnt;
                    tx_shift_reg <= tx_shift_reg;
                end
				2'b01: begin 
                    bit_cnt <= bit_cnt + 1;
                    tx_shift_reg <= tx_shift_reg >> 1;
                end
				2'b1x: begin
                    bit_cnt <= 0;
                    tx_shift_reg <= {1'b1, {tx_data}, 1'b0};
                end
				default: begin
                    bit_cnt <= 0;
                    tx_shift_reg <= 0;
                end
			endcase
            
            tx_done <= set_done & !clr_done;
        end
	end
    
	assign TX = (transmit) ? tx_shift_reg[0] : 1;	
	assign shift = (baud_cnt > 20) ? 1 : 0;

endmodule