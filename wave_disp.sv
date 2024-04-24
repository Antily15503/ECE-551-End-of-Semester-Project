module wave_disp(smpl_clk,clk,wrt_smpl,smpl,wave);
  
  input smpl_clk;
  input clk;			// main system clock (100MHz)
  input wrt_smpl;
  input [7:0] smpl;
  output reg [1:0] wave;	// reconstructed wave represented by 3 levels
  
  reg [1:0] segment;	// keep track of segment you are in;
  reg [7:0] smpld;		// represents byte that would have gone to RAM
  reg smpl_happened;
	
  always @(posedge clk)
    if (wrt_smpl) begin
	  smpl_happened <= 1;
	  smpld <= smpl;
	end

  always @(posedge smpl_clk)
    if (smpl_happened) begin
	  segment <= 2'b00;
	  smpl_happened <= 0;
	end else
      segment <= segment + 2'b01;
	  
  always @(segment) begin
    case (segment)
	  2'b00: begin
	    wave = (smpld[1]) ? 2'b10 :
		       (smpld[0]) ? 2'b01 : 2'b00;
	  end
	  2'b01: begin
	    wave = (smpld[3]) ? 2'b10 :
		       (smpld[2]) ? 2'b01 : 2'b00;
	  end
	  2'b10: begin
	    wave = (smpld[5]) ? 2'b10 :
		       (smpld[4]) ? 2'b01 : 2'b00;
	  end
	  2'b11: begin
	    wave = (smpld[7]) ? 2'b10 :
		       (smpld[6]) ? 2'b01 : 2'b00;
	  end
	endcase
  end
  
  
endmodule
  
  