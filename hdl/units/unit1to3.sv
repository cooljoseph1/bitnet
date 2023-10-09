`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit1to3 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop,
    input wire bk_prop,

    input wire fin,
    input wire [2:0] bin,

    output logic control_out, // to get the saved weight

    output logic [2:0] fout,
    output logic bout
  );

logic unused_bout1;
logic unused_bout2;

unit3to3 unit(
  .rst_in(rst_in),
  .clk_in(clk_in),
  .oscillator(oscillator),
  .fd_prop(fd_prop),
  .bk_prop(bk_prop),
  .fin({fin, 1'b1, 1'b0}),
  .bin(bin),
  .control_out(control_out),
  .fout(fout),
  .bout({unused_bout2, unused_bout1, bout})
);

endmodule // unit3to1
`default_nettype wire