module dual_pwm8_tb;
	logic[7:0] VIL, VIH;
	logic clk, rst_n;
	wire VIL_PWM, VIH_PWM;
	
	pwm8 vil(.duty(VIL), .clk(clk), .rst_n(rst_n), .PWM_sig(VIL_PWM));
	pwm8 vih(.duty(VIH), .clk(clk), .rst_n(rst_n), .PWM_sig(VIH_PWM));
	
	initial begin
		VIH = 8'd0;
		VIL = 8'hff;
		clk = 1'b0;
		rst_n = 1'b0;
		#5;
		rst_n = 1'b1;
		#1024;
		VIH = 8'd32;
		VIL = 8'd128;
		#1024;
		VIL = 8'd64;
        VIH = 8'd64;
		#1024;
		VIL = 8'd32;
        VIH = 8'd128;
		#1024;
        VIH = 8'hff;
		VIL = 8'd0;
		#1024;
		$finish;
	end
	
	always 
		#1 clk = ~clk;
		
endmodule 