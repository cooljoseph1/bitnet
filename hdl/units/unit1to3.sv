`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit1to3 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop,
    input wire bk_prop,
    input wire fin
    input wire bin0,
    input wire bin1,
    input wire bin2,
    output logic fout0,
    output logic fout1,
    output logic fout2,
    output logic bout,
    output logic control_out // to get the saved weight
  );

logic unused_bout1;
logic unused_bout2;

unit3to3 unit(
  .rst_in(rst_in),
  .clk_in(clk_in),
  .oscillator(oscillator),
  .fd_prop(fd_prop),
  .bk_prop(bk_prop),
  .fin0(0),
  .fin1(1),
  .fin2(fin),
  .bin0(bin0),
  .bin1(bin1),
  .bin2(bin2),
  .fout0(fout0),
  .fout1(fout1),
  .fout2(fout2),
  .bout0(bout),
  .bout1(unused_bout1),
  .bout2(unused_bout2),
  .control_out(control_out)
);

endmodule // unit3to1
`default_nettype wire