`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module ring_oscillator (
    output logic x
  );

  logic y, z;
  assign x = y;
  assign y = z;
  assign z = x;
endmodule // ring_oscillator
`default_nettype wire