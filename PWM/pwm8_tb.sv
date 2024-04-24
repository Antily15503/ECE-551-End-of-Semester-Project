<<<<<<< HEAD
module pwm8_tb;
	logic[7:0] duty;
	logic clk, rst_n;
	wire PWM_sig;
	
	pwm8 iDUT(.duty(duty), .clk(clk), .rst_n(rst_n), .PWM_sig(PWM_sig));
	
	initial begin
		duty = 8'hff;
		clk = 1'b0;
		rst_n = 1'b0;
		#5;
		rst_n = 1'b1;
		#1024;
		duty = 8'd128;
		#1024;
		duty = 8'd64;
		#1024;
		duty = 8'd32;
		#1024;
		duty = 8'd0;
		#1024;
		$finish;
	end
	
	always 
		#1 clk = ~clk;
		
=======
module pwm8_tb;
	logic[7:0] duty;
	logic clk, rst_n;
	wire PWM_sig;
	
	pwm8 iDUT(.duty(duty), .clk(clk), .rst_n(rst_n), .PWM_sig(PWM_sig));
	
	initial begin
		duty = 8'hff;
		clk = 1'b0;
		rst_n = 1'b0;
		#5;
		rst_n = 1'b1;
		#1024;
		duty = 8'd128;
		#1024;
		duty = 8'd64;
		#1024;
		duty = 8'd32;
		#1024;
		duty = 8'd0;
		#1024;
		$finish;
	end
	
	always 
		#1 clk = ~clk;
		
>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule 