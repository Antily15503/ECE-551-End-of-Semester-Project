module UART_tx(
  input trmt, rst_n, clk,
  input [7:0] tx_data,
  output reg tx_done,
  output TX
);
//state signals
logic init, transmitting, shift, set_done;
typedef enum {IDLE, TRAN}state_t;
state_t state, nextState;

//flop and logic signals
logic [3:0] bit_cnt;
logic [3:0] bit_temp;
logic [5:0] baud_cnt;
logic [5:0] baud_temp;
logic [8:0] tx_shft_temp;
logic [8:0] tx_shift;

//set up the init / transmitting state machine
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= nextState;
end
always_comb begin
	nextState = IDLE;
	init = 1'b0;
	set_done = 1'b0;
	transmitting = 1'b0;
	case(state)
		IDLE:
			begin
				if (trmt) begin
					init = 1'b1;
					nextState = TRAN;
				end
				else nextState = IDLE;
			end
		TRAN:
			begin
				if (bit_cnt == 4'b1010) begin
					set_done = 1'b1;
					nextState = IDLE;
				end else begin
					init = 1'b0;
					transmitting = 1'b1;
					nextState = TRAN;
				end
			end
	endcase
end

//logic unit to keep track of how many bits we have shifted
always_comb begin
	case ({init, shift})
		2'b01: bit_temp = bit_cnt + 1;
		2'b00: bit_temp = bit_cnt;
		default: bit_temp = 4'b0000;
	endcase
end
always_ff @(posedge clk) begin
	bit_cnt <= bit_temp;
end

//logic unit to keep count of baud and when to shift the next bit
always_comb begin
	case ({(init | shift), transmitting})
		2'b01: baud_temp = baud_cnt + 1;
		2'b00: baud_temp = baud_cnt;
		default: baud_temp = 6'b000000;
	endcase
end
always_ff @(posedge clk) begin
	baud_cnt <= baud_temp;
end
assign shift = (baud_cnt == 6'b100010); //check if baud_temp = 34 and asserts shift if true 

//logic unit to figure out what bit to transmit (TX)
always_comb begin
	case ({init, shift})
		2'b01: tx_shft_temp = {1'b1, tx_shift[8:1]};
		2'b00: tx_shft_temp = tx_shift[8:0];
		default: tx_shft_temp = {tx_data, 1'b0};
	endcase
end
always_ff @(posedge clk) begin
	if (!rst_n)  begin 
		tx_shift = '1;
	end 
	else tx_shift <= tx_shft_temp;
end
//splits the tx_shift values stored in the flip flop into tx_shft_reg and TX signal

assign TX = tx_shift[0];

//logic unit to figure out the TX done signal

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) tx_done <= 1'b0;
	else if (set_done) tx_done <= 1'b1;
	else if (init) tx_done <= 1'b0;
end

endmodule