module chnnl_trig(clk,CH_TrigCfg,armed,CH_Lff5,CH_Hff5,CH_Trig);

input clk;
input [4:0] CH_TrigCfg; // This should be an array for multiple channels but for simplicity, it's declared as a single vector.
input armed;
input CH_Lff5; // Assuming there are 5 such signals, one for each channel.
input CH_Hff5; // Assuming there are 5 such signals, one for each channel.
output reg CH_Trig;
	
logic [4:0] CH_ff5; // Flip-flops for each channel, these are to be triggered on the clock edge if armed.
logic bit4_ff1,bit3_ff1,bit4_ff2,bit3_ff2,bit2_ff1,bit1_ff1;

//Double flop bit 4
always_ff @(posedge CH_Hff5, negedge armed) begin
    if (!armed) begin
        bit4_ff1 <= 1'b0;	
    end else begin
		bit4_ff1 <= 1'b1;
    end
end
//Double flop bit 4
always_ff @(posedge clk) begin
		bit4_ff2 <= bit4_ff1;
end
//Double flop bit 3
always_ff @(negedge CH_Lff5, negedge armed) begin
    if (!armed) begin
        bit3_ff1 <= 1'b0;	
    end else begin
		bit3_ff1 <= 1'b1;
    end
end
//Double flop bit 3
always_ff @(posedge clk) begin
		bit3_ff2 <= bit3_ff1;
end

always_ff @(posedge clk) begin
		bit2_ff1 <= CH_Hff5;
end

always_ff @(posedge clk) begin
		bit1_ff1 <= !CH_Lff5;
end

//logic for CH_Trig
assign CH_Trig = ((bit4_ff2 && CH_TrigCfg[4])||(bit3_ff2 && CH_TrigCfg[3])||
					(bit2_ff1 && CH_TrigCfg[2])||(bit1_ff1 && CH_TrigCfg[1])|| CH_TrigCfg[0]);


endmodule