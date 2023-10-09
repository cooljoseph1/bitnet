`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module maj_gate (
    input wire control,
    input wire in1,
    input wire in2,
    input wire in3,
    output logic out;
  );
 
  assign out = ((in1 & in2) | (in2 & in3) | (in3 & in1)) ^ control;
 
endmodule // maj_gate
`default_nettype wire