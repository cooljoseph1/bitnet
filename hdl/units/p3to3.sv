`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module p3to3 (
    input wire fcontrol,
    input wire fin0,
    input wire fin1,
    input wire fin2,
    input wire bin0,
    input wire bin1,
    input wire bin2,
    output logic fout0,
    output logic fout1,
    output logic fout2,
    output logic bcontrol,
    output logic bout0,
    output logic bout1,
    output logic bout2
  );

  // forward pass
  logic fout;
  maj_gate forward(.control(fcontrol), .in0(fin0), .in1(fin1), .in2(fin2), .out(fout));
  assign fout0 = fout;
  assign fout1 = fout;
  assign fout2 = fout;
  
  // backward pass
  logic bout;
  maj_gate backward(.control(0), .in0(bin0), .in1(bin1), .in2(bin2), .out(bout));
  assign bout0 = bout;
  assign bout1 = bout;
  assign bout2 = bout;
  assign bcontrol = bout;

endmodule // p3to3
`default_nettype wire