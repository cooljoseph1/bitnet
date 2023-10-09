`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit3to1 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop,
    input wire bk_prop,
    
    input wire [2:0] fin,
    input wire bin,

    output logic control_out, // to get the saved weight

    output logic fout,
    output logic [2:0] bout
  );

logic unused_fout1;
logic unused_fout2;

unit3to3 unit(
  .rst_in(rst_in),
  .clk_in(clk_in),
  .oscillator(oscillator),
  .fd_prop(fd_prop),
  .bk_prop(bk_prop),
  .fin(fin),
  .bin({bin, 1'b1, 1'b0}),
  .control_out(control_out),
  .fout({unused_fout2, unused_fout1, fout}),
  .bout(bout)
);

endmodule // unit3to1
`default_nettype wire