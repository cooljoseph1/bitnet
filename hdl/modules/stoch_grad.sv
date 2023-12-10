module stoch_grad #(
  parameter W_SIZE = 3072
  ) (
    input wire [W_SIZE-1:0] flip_weight_in,
    output logic [W_SIZE-1:0] flip_weight_out
  );

  // TODO: MAKE THIS MODULE.
  // This module takes in whether or not weights should be flipped and zeros out almost all of them
  
endmodule // stoch_grad