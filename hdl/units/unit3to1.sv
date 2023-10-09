`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit3to1 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop,
    input wire bk_prop,
    input wire fin0,
    input wire fin1,
    input wire fin2,
    input wire bin,
    output logic fout,
    output logic bout0,
    output logic bout1,
    output logic bout2,
    output logic control_out // to get the saved weight
  );

logic unused_fout1;
logic unused_fout2;

unit3to3 unit(
  .rst_in(rst_in),
  .clk_in(clk_in),
  .oscillator(oscillator),
  .fd_prop(fd_prop),
  .bk_prop(bk_prop),
  .fin0(fin0),
  .fin1(fin1),
  .fin2(fin2),
  .bin0(0),
  .bin1(1),
  .bin2(bin),
  .fout0(fout),
  .fout1(unused_fout1),
  .fout2(unused_fout2),
  .bout0(bout0),
  .bout1(bout1),
  .bout2(bout2),
  .control_out(control_out)
);

endmodule // unit3to1
`default_nettype wire