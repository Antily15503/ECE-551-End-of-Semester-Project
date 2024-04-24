module UART_rx(
  input RX, clr_rdy, rst_n, clk,
  output reg rdy,
  output [7:0] rx_data
);
//state signals
logic start, receiving, shift, set_rdy;
typedef enum {IDLE, RECIEVE}state_t;
state_t state, nextState;

//flop and logic signals
logic [3:0] bit_cnt;
logic [3:0] bit_temp;
logic [5:0] baud_cnt;
logic [5:0] baud_temp;
logic [8:0] rx_shft_temp;
logic [8:0] rx_shift;
logic rdy_temp;

//double flopping the RX signal
logic RXi, RXf;
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		RXi <= 1;
		RXf <= 1;
	end else begin
		RXi <= RX;
		RXf <= RXi;
	end
end
//set up the init / transmitting state machine
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= nextState;
end
always_comb begin
	start = 1'b0;
	set_rdy = 1'b0;
	receiving = 1'b0;
	case(state)
		IDLE:
			begin
				if(!RXf) begin
					start = 1'b1;
					nextState = RECIEVE;
				end
			end
		RECIEVE:
			begin
				receiving = 1'b1;
				if (bit_cnt == 4'b1010) begin
					set_rdy = 1'b1;
					nextState = IDLE;
				end 
			end
	endcase
end

//logic unit to keep track of how many bits we have shifted
always_comb begin
	case ({start, shift})
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
	case ({start|shift, receiving})
		2'b01: baud_temp = baud_cnt - 1;
		2'b00: baud_temp = baud_cnt;
		default: baud_temp = start ? 6'b010001 : 6'b100010;
	endcase
end
always_ff @(posedge clk) begin
	baud_cnt <= baud_temp;
end
assign shift = ~|(baud_cnt | 6'b000000); //check if baud_temp = 0 and asserts shift if true 

//logic unit to shift bits and update the index of the recieving bit
always_comb begin
	case (shift)
		1'b0: rx_shft_temp = rx_shift;
		1'b1: rx_shft_temp = {RXf, rx_shift[8:1]};
	endcase
end
always_ff @(posedge clk) begin
	rx_shift <= rx_shft_temp;
end
//split the rx_data off of rx_shft
assign rx_data = rx_shift[7:0];

//logic unit to determing the rdy signals
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) rdy <= 1'b0;
	else if (set_rdy) rdy <= 1'b1;
	else if (start | clr_rdy) rdy <= 1'b0;
end



endmodule