module data_comp_tb();

wire prot_trig;
reg [7:0] serial_data, mask, match;
reg serial_vld;

data_comp iDut(.serial_data(serial_data), .serial_vld(serial_vld), .mask(mask), .match(match), .prot_trig(prot_trig));

initial begin
    serial_vld = 0;
    serial_data = 8'b00001111;
    match = 8'b00001111;
    mask = 8'b11111111;

    #5;
    serial_vld = 1;

    #5;
    serial_data = 8'b00001111;
    match = 8'b11110001;
    mask = 8'b00000001;

    #5;
    serial_data = 8'b10101010;
    match = 8'b01010110;
    mask = 8'b00000011;

    #5;
    serial_data = 8'b00001111;
    match = 8'b00101111;
    mask = 8'b11111111;

    #5;
    serial_data = 8'b00101111;
    match = 8'b00001111;
    mask = 8'b11111111;

    #5;
    serial_data = 8'b10001111;
    match = 8'b00001111;
    mask = 8'b01111111;

    #5;
    serial_data = 8'b00000111;
    match = 8'b00011111;
    mask = 8'b11100111;

    #5;
    serial_data = 8'b11111111;
    match = 8'b00000000;
    mask = 8'b00000000;

    #5;
    serial_data = 8'b00001111;
    match = 8'b00001111;
    mask = 8'b11111111;
    
    $finish;
    
end

endmodule