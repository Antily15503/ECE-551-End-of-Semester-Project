module data_comp(serial_data, serial_vld, mask, match, prot_trig);
	input serial_vld;
	input [7:0] serial_data, mask, match;
	output prot_trig;
	wire matchData;

    assign matchData = (serial_data | mask) == (match | mask);
    assign prot_trig = matchData & serial_vld;	
endmodule