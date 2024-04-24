module pwm8(clk, rst_n, duty, PWM_sig);
input clk, rst_n;
input [7:0] duty;
output reg PWM_sig;

logic [7:0] cnt;

always_ff @(posedge clk, negedge rst_n) begin
   if(!rst_n) begin
        PWM_sig = 0;
        cnt = 8'h00;
   end
   else if(cnt <= duty && duty != 8'h00) begin
        cnt <= cnt + 1;
        PWM_sig = 1'b1;
   end
   else if(cnt > duty && cnt !=8'hff) begin
        cnt <= cnt + 1;
        PWM_sig <= 1'b0;
   end
   else if(cnt == 8'hff)begin
        cnt <= 8'h00;
   end
   else begin
        PWM_sig <= PWM_sig;
   end
end


endmodule   