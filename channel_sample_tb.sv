`timescale 1ns / 100ps
module channel_sample_tb();
			
//// Interconnects to DUT/support defined as type wire /////
wire clk400MHz,locked;			// PLL output signals to DUT
wire clk;						// 100MHz clock generated at this level from clk400MHz
wire rst_n;						// synchronized global reset from clk_rst_smpl unit
wire VIH_PWM,VIL_PWM;			// connect to PWM outputs to monitor
wire CH_L,CH_H;					// chanel low/high inputs from AFE
wire CH_Lff5,CH_Hff5;			// 5th flopped versions of channels used for trigger logic.
wire smpl_clk;					// determines sample rate, 400MHz/2^decimator
wire wrt_smpl;					// asserted everytime new sample is ready.
wire [7:0] smpl;				// actual sample from channel_sample that would be stored in RAM
wire [1:0] wave;

////// Stimulus is declared as type reg ///////
reg REF_CLK;					// REF_CLK is 48MHz clock that feeds PLL
reg RST_n;						// RST_n is global push button reset on DE-0
reg [3:0] decimator;			// determines sample rate 0000 => 400MHz, 0001=>200MHz, 0010=>100MHz


///// Instantiate Analog Front End model for single channel  ///////
AFE_1CH iAFE(.clk400MHz(clk400MHz),.CH_L(CH_L),.CH_H(CH_H));

///// Instantiate PLL to provide 400MHz clk from 50MHz ///////
pll8x iPLL(.ref_clk(REF_CLK),.RST_n(RST_n),.out_clk(clk400MHz),.locked(locked));

///// Instantiate clk_rst_smpl /////
clk_rst_smpl iSMPL(.clk400MHz(clk400MHz),.RST_n(RST_n),.locked(locked),.decimator(decimator),
             .clk(clk),.smpl_clk(smpl_clk),.rst_n(rst_n),.wrt_smpl(wrt_smpl));

///// Instantiate DUT //////		 		  
channel_sample iDUT(.smpl_clk(smpl_clk),.clk(clk),.CH_H(CH_H),.CH_L(CH_L),
                    .CH_Hff5(CH_Hff5),.CH_Lff5(CH_Lff5),.smpl(smpl));

///// Instantiate wave reconstructor //////
wave_disp iWV(.smpl_clk(smpl_clk),.clk(clk),.wrt_smpl(wrt_smpl),
              .smpl(smpl),.wave(wave));
					  

initial begin
  REF_CLK = 0;
  RST_n = 0;
  decimator = 4'b0010;

  @(negedge REF_CLK);
  RST_n = 1;
  
  @(posedge locked);
  @(negedge clk);
  RST_n = 1;
  
  repeat(500) @(posedge REF_CLK);
  
  $stop();
end

always
  #10.4 REF_CLK = ~REF_CLK;


endmodule	
