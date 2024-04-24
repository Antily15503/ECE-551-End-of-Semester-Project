<<<<<<< HEAD
module dual_PWM(clk, rst_n, VIL, VIH, VIL_PWM, VIH_PWM);
input clk, rst_n;
input[7:0] VIL, VIH;
output VIL_PWM, VIH_PWM;


pwm8 vil(.clk(clk), .rst_n(rst_n), .duty(VIL), .PWM_sig(VIL_PWM));
pwm8 vih(.clk(clk), .rst_n(rst_n), .duty(VIH), .PWM_sig(VIH_PWM));

=======
module dual_pwm8(clk, rst_n, VIL, VIH, VIL_PWM, VIH_PWM);
input clk, rst_n;
input[7:0] VIL, VIH;
output VIL_PWM, VIH_PWM;


pwm8 vil(.clk(clk), .rst_n(rst_n), .duty(VIL), .PWM_sig(VIL_PWM));
pwm8 vih(.clk(clk), .rst_n(rst_n), .duty(VIH), .PWM_sig(VIH_PWM));

>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule