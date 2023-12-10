# Instruction set

Here is the instruction set according to the SystemVerilog file:

  localparam SET_I_TO_0 = 0; // "I = 0"
  localparam SET_TRIT_TO_NEXT_VALUE = 1; // "TRIT = NEXT"
  localparam SET_H_TO_NEXT_VALUE = 2; // "H = NEXT"
  localparam D_INCREMNT = 3; // "D++"
  localparam D_DECREMNT = 4; // "D--"
  localparam A_INCREMNT = 5; // "A++"
  localparam A_DECREMNT = 6; // "A--"
  localparam SET_X_TO_VALUE_AT_D0 = 7; // "X = *D[0]"
  localparam SET_Y_TO_VALUE_AT_D1 = 8; // "Y = *D[1]"
  localparam SET_XY_TO_VALUE_AT_D = 9; // "X, Y = *D"
  localparam SET_INFERENCE_TO_Y = 10; // "INFERENCE = Y"
  localparam SET_W_TO_VALUE_AT_A = 11; // "W = *A"
  localparam SET_VALUE_AT_A_TO_W = 12; // "*A = W"
  localparam SET_X_TO_VALUE_AT_H = 13; // "X = *H"
  localparam SET_VALUE_AT_H_TO_X = 14; // "*H = X"
  localparam SWAP_XY = 15; // "X, Y = Y, X"
  localparam SET_X_TO_Y = 16; // "X = Y"
  localparam SET_Y_TO_X = 17; // "Y = X"
  localparam SET_X_TO_X_XOR_Y = 18; // "X = X ^ Y"
  localparam SET_Y_TO_X_XOR_Y = 19; // "Y = X ^ Y"
  localparam SET_X_TO_X_AND_Y = 20; // "X = X & Y"
  localparam SET_Y_TO_X_AND_Y = 21; // "Y = X & Y"
  localparam SET_X_TO_X_OR_Y = 22; // "X = X | Y"
  localparam SET_Y_TO_X_OR_Y = 23; // "Y = X | Y"
  localparam INTERWEAVE = 24; // "INTERWEAVE"
  localparam BACKPROP = 25; // "BACKPROP"
  localparam STOCH_GRAD = 26; // "STOCH GRAD"