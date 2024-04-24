<<<<<<< HEAD
module dff(D,clk,PRN,Q);

  /////////////////////////////////////////
  // D-FF with active low asynch preset //
  ///////////////////////////////////////

  input D;
  input clk;
  input PRN;		// active low preset (sets to 1)
  output reg Q;

  always @(posedge clk, negedge PRN)
    if (!PRN)
	  Q<= 1'b1;
	else
      Q <= D;
  
=======
module dff(D,clk,PRN,Q);

  /////////////////////////////////////////
  // D-FF with active low asynch preset //
  ///////////////////////////////////////

  input D;
  input clk;
  input PRN;		// active low preset (sets to 1)
  output reg Q;

  always @(posedge clk, negedge PRN)
    if (!PRN)
	  Q<= 1'b1;
	else
      Q <= D;
  
>>>>>>> 82fee69a4068e53e80df778b5b5ffacfbc43220c
endmodule