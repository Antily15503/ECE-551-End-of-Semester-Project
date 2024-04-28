module cmd_cfg(clk,rst_n,resp,send_resp,resp_sent,cmd,cmd_rdy,clr_cmd_rdy,
               set_capture_done,raddr,rdataCH1,rdataCH2,rdataCH3,rdataCH4,
			   rdataCH5,waddr,trig_pos,decimator,maskL,maskH,matchL,matchH,
			   baud_cntL,baud_cntH,TrigCfg,CH1TrigCfg,CH2TrigCfg,CH3TrigCfg,
			   CH4TrigCfg,CH5TrigCfg,VIH,VIL);
			   
  parameter ENTRIES = 384,	// defaults to 384 for simulation, use 12288 for DE-0
            LOG2 = 9;		// Log base 2 of number of entries
			
  input clk,rst_n;
  input [15:0] cmd;			// 16-bit command from UART (host) to be executed
  input cmd_rdy;			// indicates command is valid
  input resp_sent;			// indicates transmission of resp[7:0] to host is complete
  input set_capture_done;	// from the capture module (sets capture done bit in TrigCfg)
  input [LOG2-1:0] waddr;		// on a dump raddr is initialized to waddr
  input [7:0] rdataCH1;		// read data from RAMqueues
  input [7:0] rdataCH2,rdataCH3;
  input [7:0] rdataCH4,rdataCH5;
  output logic [7:0] resp;		// data to send to host as response (formed in SM)
  output send_resp;				// used to initiate transmission to host (via UART)
  output reg clr_cmd_rdy;			// when finished processing command use this to knock down cmd_rdy
  output reg [LOG2-1:0] raddr;		// read address to RAMqueues (same address to all queues)
  output [LOG2-1:0] trig_pos;	// how many sample after trigger to capture
  output reg [3:0] decimator;	// goes to clk_rst_smpl block
  output reg [7:0] maskL,maskH;				// to trigger logic for protocol triggering
  output reg [7:0] matchL,matchH;			// to trigger logic for protocol triggering
  output reg [7:0] baud_cntL,baud_cntH;		// to trigger logic for UART triggering
  output reg [5:0] TrigCfg;					// some bits to trigger logic, others to capture unit
  output reg [4:0] CH1TrigCfg,CH2TrigCfg;	// to channel trigger logic
  output reg [4:0] CH3TrigCfg,CH4TrigCfg;	// to channel trigger logic
  output reg [4:0] CH5TrigCfg;				// to channel trigger logic
  output reg [7:0] VIH,VIL;					// to dual_PWM to set thresholds
  
  //internal signals
  logic set_addr_ptr, write_en, increment_addr, send_resp_ss;
  logic [7:0] trig_posL;
  logic [LOG2-9:0] trig_posH;
  //state definition
  typedef enum reg[3:0] {IDLE,WRITE,POSACK,NEGACK,READ,DUMP1,DUMP2, WAIT1, WAIT2 } state_t;
  
  state_t state,next_state;
  
 // State Logic
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) 
        state <= IDLE;
    else
        state <= next_state;
end

 // State Machine
always_comb begin

  set_addr_ptr = 1'b1;
  send_resp_ss = 1'b0;
  resp = 8'h00;
  write_en = 1'b0;
  increment_addr = 1'b0;
  clr_cmd_rdy = 1'b0;
  next_state = state;

  case (state)
    IDLE: begin
      send_resp_ss = 1'b0;
      if (!cmd_rdy) next_state = IDLE;
      else if (cmd_rdy) begin
        case (cmd [15:14])
          2'b00: next_state = READ;
          2'b01: next_state = WRITE;
          2'b10: begin
            next_state = DUMP1;
          end
          default: next_state = NEGACK;	//Handle unrecognized commands
        endcase
      end
    end
    READ: begin
      //Logic to handle READ operations based on command specifics
      case (cmd[13:8])
        6'h00: resp = TrigCfg;
        6'h01: resp = CH1TrigCfg;
        6'h02: resp = CH2TrigCfg;
        6'h03: resp = CH3TrigCfg;
        6'h04: resp = CH4TrigCfg;
        6'h05: resp = CH5TrigCfg;
        6'h06: resp = decimator;
        6'h07: resp = VIH;
        6'h08: resp = VIL;
        6'h09: resp = matchH;
        6'h0A: resp = matchL;
        6'h0B: resp = maskH;
        6'h0C: resp = maskL;
        6'h0D: resp = baud_cntH;
        6'h0E: resp = baud_cntL;
        6'h0F: resp = trig_posH;
        6'h10: resp = trig_posL;
      endcase
      send_resp_ss = 1'b1;
      next_state = IDLE;
      clr_cmd_rdy = 1'b1;
    end
    NEGACK: begin
	// Negative acknowledgement for invalid commands
      send_resp_ss = 1'b1;
      resp = 8'hEE;
      next_state = IDLE;
      clr_cmd_rdy = 1'b1;
    end
    WRITE: begin
      write_en = 1'b1;
      next_state = POSACK;
    end
    POSACK: begin
	// Acknowledge successful write operation
      send_resp_ss = 1'b1;
      resp = 8'hA5;
      next_state = IDLE;
      clr_cmd_rdy = 1'b1;
    end
    DUMP1: begin
		// Handle data dumping from specified RAM queue
      if (raddr == waddr) begin 
        next_state = WAIT1;
        clr_cmd_rdy = 1'b1;
      end
      else begin
        next_state = DUMP2;
        send_resp_ss = 1'b1;
      end
      case(cmd[10:8]) 
        3'b001: resp = rdataCH1;
        3'b010: resp = rdataCH2;
        3'b011: resp = rdataCH3;
        3'b100: resp = rdataCH4;
        3'b101: resp = rdataCH5;
      endcase
      increment_addr = 1'b1;
      set_addr_ptr = 0;

    end
    DUMP2: begin
      set_addr_ptr = 0;
      if (resp_sent) begin
        next_state = DUMP1;
      end
    end
    WAIT1: begin
      set_addr_ptr = 0;
      next_state = WAIT2;
    end
    WAIT2: begin
      set_addr_ptr = 0;
      next_state = DUMP1;
    end
  endcase
end

//concatenation for trig_pos signal
assign trig_pos = {trig_posH, trig_posL};
assign send_resp = send_resp_ss;

logic [LOG2-1:0] waddr_new;

//flip flop for dumping address
always_ff @(posedge clk) begin
  if(waddr > (ENTRIES-1))
    waddr_new <= waddr - ENTRIES -1;
  else
    waddr_new <= waddr;
  if (set_addr_ptr) raddr <= waddr_new;
  else if (increment_addr) begin
    raddr <= (raddr == 9'd383) ? 9'h000 : raddr+1;
  end
  
end

  // TrigCfg register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    TrigCfg <= 6'h03; // Reset value
  else if (write_en && (cmd[13:8] == 6'h00)) begin
    TrigCfg <= cmd[5:0]; // Value to write to the register
  end
  else if (set_capture_done) begin
    TrigCfg[5] <= 1'b1;
    TrigCfg[4] <= 1'b0;
  end
end

// CH1TrigCfg register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    CH1TrigCfg <= 5'h01; // Reset value
  else if (write_en && (cmd[13:8] == 6'h01))
    CH1TrigCfg <= cmd[4:0]; // Value to write to the register
end

// CH2TrigCfg register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    CH2TrigCfg <= 5'h01; // Reset value
  else if (write_en && (cmd[13:8] == 6'h02))
    CH2TrigCfg <= cmd[4:0]; // Value to write to the register
end

// CH3TrigCfg register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    CH3TrigCfg <= 5'h01; // Reset value
  else if (write_en && (cmd[13:8] == 6'h03))
    CH3TrigCfg <= cmd[4:0]; // Value to write to the register
end

// CH4TrigCfg register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    CH4TrigCfg <= 5'h01; // Reset value
  else if (write_en && (cmd[13:8] == 6'h04))
    CH4TrigCfg <= cmd[4:0]; // Value to write to the register
end

// CH5TrigCfg register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    CH5TrigCfg <= 5'h01; // Reset value
  else if (write_en && (cmd[13:8] == 6'h05))
    CH5TrigCfg <= cmd[4:0]; // Value to write to the register
end

// decimator register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    decimator <= 4'h0; // Reset value
  else if (write_en && (cmd[13:8] == 6'h06))
    decimator <= cmd[3:0]; // Value to write to the register
end

// VIH register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    VIH <= 8'hAA; // Reset value
  else if (write_en && (cmd[13:8] == 6'h07))
    VIH <= cmd[7:0]; // Value to write to the register
end

// VIL register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    VIL <= 8'h55; // Reset value
  else if (write_en && (cmd[13:8] == 6'h08))
    VIL <= cmd[7:0]; // Value to write to the register
end

// matchH register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    matchH <= 8'h00; // Reset value
  else if (write_en && (cmd[13:8] == 6'h09))
    matchH <= cmd[7:0]; // Value to write to the register
end

// matchL register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    matchL <= 8'h00; // Reset value
  else if (write_en && (cmd[13:8] == 6'h0A))
    matchL <= cmd[7:0]; // Value to write to the register
end

// maskH register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    maskH <= 8'h00; // Reset value
  else if (write_en && (cmd[13:8] == 6'h0B))
    maskH <= cmd[7:0]; // Value to write to the register
end

// maskL register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    maskL <= 8'h00; // Reset value
  else if (write_en && (cmd[13:8] == 6'h0C))
    maskL <= cmd[7:0]; // Value to write to the register
end

// baud_cntH register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    baud_cntH <= 8'h06; // Reset value
  else if (write_en && (cmd[13:8] == 6'h0D))
    baud_cntH <= cmd[7:0]; // Value to write to the register
end

// baud_cntL register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    baud_cntL <= 8'hC8; // Reset value
  else if (write_en && (cmd[13:8] == 6'h0E))
    baud_cntL <= cmd[7:0]; // Value to write to the register
end

// trig_posH register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    trig_posH <= 8'h00;
  else if (write_en && (cmd[13:8] == 6'h0F))
    trig_posH <= cmd[7:0];
end

//trig_posL register
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    trig_posL <= 8'h01;
  else if (write_en && (cmd[13:8] == 6'h10))
    trig_posL <= cmd[7:0];
end

endmodule
  