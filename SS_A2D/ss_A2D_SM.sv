module ss_A2D_SM(clk,rst_n,strt_cnv,smp_eq_8,gt,clr_dac,inc_dac,
                 clr_smp,inc_smp,accum,cnv_cmplt);

  input clk,rst_n;			// clock and asynch reset
  input strt_cnv;			// asserted to kick off a conversion
  input smp_eq_8;			// from datapath, tells when we have 8 samples
  input gt;					// gt signal, has to be double flopped
  
  output logic clr_dac;			// clear the input counter to the DAC
  output inc_dac;			// increment the counter to the DAC
  output clr_smp;			// clear the sample counter
  output inc_smp;			// increment the sample counter
  output accum;				// asserted to make accumulator accumulate sample
  output cnv_cmplt;			// indicates when the conversion is complete

  /////////////////////////////////////////////////////////////////
  // You fill in the SM implementation. I want to see the use   //
  // of enumerated type for state, and proper SM coding style. //
  //////////////////////////////////////////////////////////////
  typedef enum logic [1:0] {IDLE, CNV, ACCUM} state_t;
  state_t state, nxt_state;
  //cast as type logic so they can be assigned in an always_comb block
  logic inc_dac, clr_smp, inc_smp, accum, cnv_cmplt;

  logic gt_sync_0, gt_sync_1;
  //async reset on negedge rst_n
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
      state <= IDLE;
    end
    else begin
      state <= nxt_state;
    end
  end

//double flop gt
  always_ff@(posedge clk) begin 
    gt_sync_0 <= gt;
    if(clr_dac) begin
      gt_sync_0 <= 1'b0;
    end
  end
  always_ff@(posedge clk) begin 
    gt_sync_1 <= gt_sync_0;
    if(clr_dac) begin
      gt_sync_1 <= 1'b0;
    end
  end

  always_comb begin
    //default assignments to prevent latches
    nxt_state = IDLE;
    clr_dac = 1'b0;
    clr_smp = 1'b0;
    accum = 1'b0;
    inc_dac = 1'b0;
    clr_dac = 1'b0;
    inc_smp = 1'b0;
    cnv_cmplt = 1'b0;
      case(state)
        IDLE: begin
          if(strt_cnv) begin
            clr_dac = 1'b1;
            clr_smp = 1'b1;
            nxt_state = CNV;
          end
        end
        CNV: begin
          if(gt_sync_1) begin
            accum = 1'b1;
            nxt_state = ACCUM;
          end
          else begin
            inc_dac = 1'b1;
            nxt_state = CNV;
          end
        end
        ACCUM: begin
          if(!smp_eq_8) begin
            clr_dac = 1'b1;
            inc_smp = 1'b1;
            nxt_state = CNV;
          end
          else begin
            cnv_cmplt = 1'b1;
            nxt_state = IDLE;
          end
        end
      endcase
  end
  
  
endmodule
  
					   