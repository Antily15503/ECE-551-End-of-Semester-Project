module ComSender(
  input [15:0] cmd,
  input snd_cmd, clk, rst_n, RX,
  output [7:0]resp,
  output reg resp_rdy, cmd_sent, TX
);
//control SM signals
typedef enum reg [1:0] {IDLE, HIGH, LOW} state_t;
state_t state, nxt_state;
reg sel, trmt, tx_done, set_cmd_snt;
//other signals
reg [7:0] cmd_ff;
reg [7:0] tx_data;

always_ff @(posedge clk) begin
  if (snd_cmd) cmd_ff <= cmd[7:0];
end

//building mux that selects which cmd signal to use
assign tx_data = sel ? cmd[15:8] : cmd_ff;

//initializing the transceiver
UART ts(.tx_data(tx_data), .trmt(trmt), .clr_rx_rdy(resp_rdy), .clk(clk), .rst_n(rst_n), .RX(RX), .rx_data(resp), .rx_rdy(resp_rdy), .TX(TX), .tx_done(tx_done));

//setting up the cmd_snt signal
always_ff @ (posedge clk, negedge rst_n) begin
  if (!rst_n) cmd_sent <= 1'b0;
  else if (snd_cmd) cmd_sent <= 1'b0;
  else if (set_cmd_snt) cmd_sent <= 1'b1;
end

//setting up the Control State Machine
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= nxt_state;
end

//always comp block for state machine
always_comb begin
  sel = 1'b0;
  trmt = 1'b0;
  nxt_state = IDLE;
  set_cmd_snt = 1'b0;

  case (state)
    IDLE: begin
      if (!snd_cmd) nxt_state = IDLE;
      else begin
        nxt_state = HIGH;
        trmt = 1'b1;
        sel = 1'b1;
      end
    end
    HIGH: begin
      if (!tx_done) begin 
        sel = 1'b1;
        nxt_state = HIGH;
      end else begin
        trmt = 1'b1;
        sel = 1'b0;
        nxt_state = LOW;
      end
    end
    LOW: begin
      if (!tx_done) begin
        sel = 1'b0;
        nxt_state = LOW;
      end else begin
        set_cmd_snt = 1'b1;
        nxt_state = IDLE;
      end
    end
  endcase
end
endmodule