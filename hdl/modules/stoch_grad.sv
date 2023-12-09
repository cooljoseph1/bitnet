`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module stoch_grad #(
  parameter W_SIZE = 1024,
  ) (
    input wire [W_SIZE-1:0] flip_weight_in,
    output logic [W_SIZE-1:0] flip_weight_out
  );

  // TODO: MAKE THIS MODULE.
  // This module takes in whether or not weights should be flipped and zeros out almost all of them
  
endmodule // stoch_grad
`default_nettype wire