`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module maj3_gate (
    input wire control,
    input wire [2:0] in,
    output logic out
  );
 
  assign out = (in[0] & in[1]) ^ (in[1] & in[2]) ^ (in[2] & in[0]) ^ control;
 
endmodule // maj3_gate
`default_nettype wire