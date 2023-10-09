`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module perceptron (
    input wire fcontrol,
    input wire fin1,
    input wire fin2,
    input wire fin3,
    input wire bin1,
    input wire bin2,
    input wire bin3,
    output logic fout1,
    output logic fout2,
    output logic fout3,
    output logic bcontrol,
    output logic bout1,
    output logic bout2,
    output logic bout3,
  );

  // forward pass
  logic fout;
  maj_gate forward(.control(fcontrol), .in1(fin1), .in2(fin2), .in3(fin3), .out(fout));
  assign fout1 = fout;
  assign fout2 = fout;
  assign fout3 = fout;
  
  // backward pass
  logic bout;
  maj_gate forward(.control(0), .in1(bin1), .in2(bin2), .in3(bin3), .out(bout));
  assign bout1 = bout;
  assign bout2 = bout;
  assign bout3 = bout;
  assign bcontrol = bout;

endmodule // perceptron
`default_nettype wire