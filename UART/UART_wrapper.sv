module UART_Wrapper(clk, rst_n, clr_cmd_rdy, cmd_rdy, cmd, send_resp, resp, resp_sent, RX, TX);
	input clk, rst_n, clr_cmd_rdy, send_resp, RX;
	input[7:0] resp;
	output logic cmd_rdy, resp_sent, TX;
	output [15:0] cmd;
	logic rdy, clr_rdy, load, clr_cmd_rdy_OUT;
	wire[7:0] rx_data;
	logic set_cmd_rdy, clr_cmd_rdy_SM;
	logic[7:0] first_byte;
	typedef enum logic {IDLE, LOAD_HIGH} state_t;
	state_t state, nxt_state;
	
	UART iUART(.clk(clk), .rst_n(rst_n), .trmt(send_resp), .tx_data(resp), .tx_done(resp_sent), .TX(TX), .RX(RX), .rx_rdy(rdy), .rx_data(rx_data), .clr_rx_rdy(clr_rdy));
	
	//Store the first 8 bites of 16 bit message
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			state <= IDLE;
			first_byte <= 0;
		end
		else begin
			state <= nxt_state;
			first_byte <= (load == 1) ? rx_data : first_byte; 
		end
	end
	
	always_comb begin
		set_cmd_rdy = 0;
		clr_cmd_rdy_SM = 0;
		clr_rdy = 0;
		load = 0;
		nxt_state = IDLE;
		
		case(state) 
			IDLE: begin
				if(rdy) begin
					clr_rdy = 1;
					clr_cmd_rdy_SM = 1;
					load = 1;
					nxt_state = LOAD_HIGH;
				end
				else
					nxt_state = IDLE;
			end
			LOAD_HIGH: begin
				if(rdy) begin
					clr_rdy = 1;
					set_cmd_rdy = 1;
					nxt_state = IDLE;
				end
				else begin
					load = 1;
					nxt_state = LOAD_HIGH;
				end
			end
		endcase
	end
	
	// cmd_rdy logic
	assign clr_cmd_rdy_OUT = clr_cmd_rdy | clr_cmd_rdy_SM;
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			cmd_rdy <= 0;
		else if(set_cmd_rdy)
			cmd_rdy <= 1;
		else if(clr_cmd_rdy_OUT)
			cmd_rdy <= 0;
		else
			cmd_rdy <= cmd_rdy;
	end
	assign cmd = {first_byte, rx_data};
	
endmodule