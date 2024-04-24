<<<<<<< HEAD
module ComSender(clk,rst_n,RX,TX,cmd_snt,resp_rdy,resp,snd_cmd,cmd);
// Command Sender

input clk, rst_n;
input RX;
input [15:0] cmd;
input snd_cmd;
output TX;
output reg cmd_snt;
output resp_rdy;
output [7:0] resp;

typedef enum logic [1:0] {IDLE,SEND_HIGH,SEND_LOW} state_t;
state_t state, next_state;

// Internal signals
logic trmt, tx_done, sel_high, set_cmd_snt;
logic [7:0] tx_byte;
logic [7:0] cmd_low_byte;

// Instantiate the 8-bit UART module 
UART iUART(.clk(clk), .rst_n(rst_n), .TX(TX), .RX(RX), .trmt(trmt), .clr_rx_rdy(resp_rdy)
        , .tx_data(tx_byte), .rx_rdy(resp_rdy), .tx_done(tx_done), .rx_data(resp));

// State Machine
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) 
        state <= IDLE;
    else
        state <= next_state;
end

// Hold byte register logic
always_ff @(posedge clk) begin 
    if (snd_cmd) 
        cmd_low_byte <= cmd[7:0];
end

// Select byte register logic
always_ff @(posedge clk) begin 
    if (sel_high) 
        tx_byte <= cmd[15:8];
	else
		tx_byte <= cmd_low_byte;
end

// cmd_snt logic
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            cmd_snt <= 1'b0;
        else if (snd_cmd)	
            cmd_snt <= 1'b0;
        else if (set_cmd_snt)		
            cmd_snt <= 1'b1;
    end

// State transitions
always_comb begin
	// default outputs
	sel_high = 0;
	trmt = 0;
	set_cmd_snt = 0;
	next_state = state;
        case (state)	
		IDLE: begin              
            if (snd_cmd) begin
				sel_high = 1'b1;
                next_state = SEND_HIGH;
            end 
        end	
		SEND_HIGH: begin	
			trmt = 1;
            if (tx_done) begin
				sel_high = 1'b0;
                next_state = SEND_LOW;
            end 
        end	
		SEND_LOW: begin	
			trmt = 1;
            if (tx_done) begin
				set_cmd_snt = 1'b1;
                next_state = IDLE;
            end 
        end
        endcase
    end
endmodule
=======
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


	UART iUART(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .TX(TX), .RX(RX), .rx_rdy(resp_rdy), .rx_data(resp), .clr_rx_rdy(clr_resp_rdy));

	// State machine registers
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end

	always_comb begin
		sel = 0;
		trmt = 0;
		nxt_state = IDLE;
		cmd_sent = 0;
		
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
					cmd_sent = 1;
					nxt_state = CMD_SENT;
				end
			end
			CMD_SENT: begin
				if(!send_cmd) begin
					cmd_sent = 1;
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
>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
