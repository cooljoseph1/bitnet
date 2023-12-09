`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module binterweave #(
  parameter X_SIZE = 1024,
  parameter W_SIZE = 1024,
  parameter TRIT_SIZE = 4,
  ) (
    input wire [X_SIZE-1:0] y,
    input wire [W_SIZE-1:0] w,
    input wire [TRIT_SIZE-1:0] trit,
    output logic [X_SIZE-1:0] x,
    output logic [W_SIZE-1:0] grad,
  );

  // TODO: MAKE THIS MODULE

endmodule // interweave
`default_nettype wire