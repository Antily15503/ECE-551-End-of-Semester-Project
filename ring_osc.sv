<<<<<<< HEAD
module ringOsc(input en, output out);

wire nandOut, notOut1, notOut2;

nand #5 (nandOut, en, notOut2);
not #5 (notOut1, nandOut);
not #5 (notOut2, notOut1);

assign out = notOut2;

=======
module ringOsc(input en, output out);

wire nandOut, notOut1, notOut2;

nand #5 (nandOut, en, notOut2);
not #5 (notOut1, nandOut);
not #5 (notOut2, notOut1);

assign out = notOut2;

>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule