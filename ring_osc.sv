module ringOsc(input en, output out);

wire nandOut, notOut1, notOut2;

nand #5 (nandOut, en, notOut2);
not #5 (notOut1, nandOut);
not #5 (notOut2, notOut1);

assign out = notOut2;

endmodule