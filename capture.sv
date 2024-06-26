module capture(clk,rst_n,wrt_smpl,run,capture_done,triggered,trig_pos,
               we,waddr,set_capture_done,armed);

  parameter ENTRIES = 384,		// defaults to 384 for simulation, use 12288 for DE-0
            LOG2 = 9;			// Log base 2 of number of entries
  
  input clk;					// system clock.
  input rst_n;					// active low asynch reset
  input wrt_smpl;				// from clk_rst_smpl.  Lets us know valid sample ready
  input run;					// signal from cmd_cfg that indicates we are in run mode
  input capture_done;			// signal from cmd_cfg register.
  input triggered;				// from trigger unit...we are triggered
  input [LOG2-1:0] trig_pos;	// How many samples after trigger do we capture
  
  output logic we;					// write enable to RAMs
  output reg [LOG2-1:0] waddr;	// write addr to RAMs
  output logic set_capture_done;		// asserted to set bit in cmd_cfg
  output reg armed;				// we have enough samples to accept a trigger

  /// declare state register as type enum ///
  typedef enum logic [1:0] {IDLE, WRITE, DONE} state_t;
  state_t state, nxt_state;
  /// declare needed internal registers
  
  logic inc_waddr, inc_trig_cnt, clr_waddr, clr_trig_cnt;
  logic [LOG2-1:0] trig_cnt;

  logic assert_armed, deassert_armed, assert_capture, deassert_capture;

  //// you fill in the rest ////
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      state <= IDLE;
    end
    else begin
      state <= nxt_state;
    end
  end

  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      waddr <= 0;
    end
    else if(clr_waddr)
      waddr<= '0;
    else if(inc_waddr)
      waddr <= waddr + 1;

  end
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      trig_cnt <= 0;
    end
    else if(clr_trig_cnt)
      trig_cnt <= 0;
    else if(inc_trig_cnt)
      trig_cnt <= trig_cnt + 1;

  end

always_ff @(posedge clk, negedge rst_n) begin
  if(!rst_n) begin
    armed <= 0;
  end
  else if (assert_armed)
    armed <= 1;
  else if(deassert_armed)
    armed<=0;
end

always_ff @(posedge clk, negedge rst_n)begin
  if(!rst_n) begin
    set_capture_done <= 0;
  end
  else if(assert_capture)
    set_capture_done <= 1;
  else if(deassert_capture)
    set_capture_done <= 0;
  else
    set_capture_done <= set_capture_done;
end

  always_comb begin
    nxt_state = IDLE;
    assert_armed = 0;
    deassert_armed = 0;
    assert_capture = 0;
    deassert_capture = 0;
    we = 0;
    inc_waddr = 0;
    inc_trig_cnt = 0;
    clr_waddr = 0;
    clr_trig_cnt = 0;
    
    case(state)
      IDLE: begin
        if(!run) begin
          nxt_state = IDLE;
        end
        else if(run) begin
          clr_waddr = 1;
          clr_trig_cnt = 1; 
          nxt_state = WRITE;
        end
      end

      WRITE: begin
        if(wrt_smpl) begin
          we = 1;
          if(!triggered) begin
            inc_waddr = 1; 
            if(waddr + trig_pos == ENTRIES - 1) begin
              assert_armed = 1;
            end
            nxt_state = WRITE;
          end
          else begin
            inc_trig_cnt = 1;
            if(trig_cnt == trig_pos) begin
              nxt_state = DONE;
              assert_capture = 1;
              deassert_armed = 1;
            end
            else begin
              inc_waddr = 1;
              nxt_state = WRITE;
            end
          end
        end
        else
          nxt_state = WRITE;
      end

      DONE: begin
        if(!capture_done) begin
          nxt_state = IDLE;
          deassert_capture = 1; 
        end
        else begin
          nxt_state = DONE;
          deassert_capture = 1;
        end

      end
    endcase
  end

endmodule
