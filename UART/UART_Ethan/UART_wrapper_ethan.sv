module UART_wrapper_ethan(
  input RX,clk, rst_n, clr_cmd_rdy, send_resp,
  input [7:0] resp,
  output reg cmd_rdy, resp_sent, TX,
  output reg [15:0] cmd
);
//state signals
logic clr_rdy, rx_rdy, switch, rdy, rst_rdy;
typedef enum {LOW, HIGH}state_t;
state_t state, nextState;

//instantiating the UART
reg [7:0] rx_data;
UART nUART(.RX(RX), .TX(TX), .clk(clk), .rst_n(rst_n), .rx_rdy(rx_rdy), .rx_data(rx_data), .clr_rx_rdy(clr_rdy), .trmt(send_resp), .tx_data(resp), .tx_done(resp_sent));

//flopping rx_rdy for rising edge signal
reg rx_ff, rx_rising;
always_ff @(posedge clk, negedge rst_n) begin
	rx_ff <= rx_rdy;
end
assign rx_rising = (rx_rdy & ~rx_ff);
//state machine logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= LOW;
	else state <= nextState;
end
always_comb begin
	switch = 1'b0;
	clr_rdy = 1'b0;
	rdy = 1'b0;
	rst_rdy = 1'b0;
	case (state)
		LOW:
			if (rx_rising) begin
				nextState = HIGH;
				clr_rdy = 1'b1;
				switch = 1'b1;
				rst_rdy = 1'b1;
			end else begin
				nextState = LOW;
				switch = 1'b0;
			end
		HIGH:
			if (rx_rising) begin
				nextState = LOW;
				rdy = 1'b1;
				switch = 1'b0;
			end else begin
				nextState = HIGH;
				switch = 1'b1;
			end
	endcase
end
//logic for command byte synthesis and joiner
reg [7:0] upperCmd;
always_ff @(posedge clk) begin
	upperCmd <= switch ? upperCmd : rx_data;
end
//flopping the command signal so it doesn't get updated in the future
always_ff @(posedge clk) begin
	cmd <= (~(rdy || cmd_rdy)) ? {upperCmd, rx_data} : cmd;
end

//asserting the cmd_rdy signal
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) cmd_rdy <= 1'b0;
	else if (rdy) cmd_rdy <= 1'b1;
	else if (clr_cmd_rdy || rst_rdy) cmd_rdy <= 1'b0;
end
endmodule