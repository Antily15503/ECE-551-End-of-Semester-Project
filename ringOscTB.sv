<<<<<<< HEAD
module tb_ringOsc();
wire out;
reg en;

ringOsc iDUT(.en(en), .out(out));

initial begin
    #15;
    en = 1;
    #5;
    en = 0;
    #5 $stop();
end

=======
module tb_ringOsc();
wire out;
reg en;

ringOsc iDUT(.en(en), .out(out));

initial begin
    #15;
    en = 1;
    #5;
    en = 0;
    #5 $stop();
end

>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule