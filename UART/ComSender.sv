module ComSender(clk, rst_n, cmd, send_cmd, TX, RX, cmd_sent, resp_rdy, resp, clr_resp_rdy);
	input clk, rst_n, send_cmd, RX, clr_resp_rdy;
	input[15:0] cmd;
	output TX, resp_rdy;
	output reg cmd_sent;
	output[7:0] resp;
	reg tx_done, sel, trmt;
	wire[7:0] tx_data;
	reg[7:0] low_bytes;
	
	typedef enum reg[1:0] {IDLE, LHB, LLB, CMD_SENT} state_t;
	state_t state, nxt_state;

	logic set_cmd_sent;

	UART iUART(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX), .RX(RX), .rx_rdy(resp_rdy), .rx_data(resp), .clr_rx_rdy(clr_resp_rdy));

	// State machine registers
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end

	always@(posedge clk) begin
		if(!rst_n)
			cmd_sent <= 0;
		else
			cmd_sent <= set_cmd_sent;

	end
	
	always_comb begin
		sel = 0;
		trmt = 0;
		nxt_state = IDLE;
		set_cmd_sent = 0;
		
		case(state)
			IDLE: begin
				if(send_cmd) begin
					trmt = 1;
					sel = 1;
					nxt_state = LHB;
				end
				else	
					nxt_state = IDLE;
			end
			LHB: begin
				if(!tx_done) begin
					nxt_state = LHB;
				end
				else begin
					trmt = 1;
					nxt_state = LLB;
				end
			end
			LLB: begin
				if(!tx_done) begin
					nxt_state = LLB;
				end
				else begin
					set_cmd_sent = 1;
					nxt_state = CMD_SENT;
				end
			end
			CMD_SENT: begin
				if(!send_cmd) begin
					set_cmd_sent = 1;
					nxt_state = CMD_SENT;
				end
				else begin
					trmt = 1;
					sel = 1;
					nxt_state = LHB;
				end
			end
		endcase
		
	end
	
	// Store the low byte on a send_cmd to be sent later
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			low_bytes <= 8'b0;
		else if(send_cmd)
			low_bytes <= cmd[7:0];
		else
			low_bytes <= low_bytes;
	end
	
	assign tx_data = sel ? cmd[15:8] : low_bytes;

endmodule
