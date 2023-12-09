`timescale 1ns / 1ps
`default_nettype none; // prevents system from inferring an undeclared logic (good practice)


module cpu #(
    parameter PROGRAM_LENGTH = 256,
    parameter DATA_LENGTH = 256,
    parameter WEIGHT_LENGTH = 256,
    parameter INSTRUCTION_SIZE = 8,
    parameter X_SIZE = 1024,
    parameter W_SIZE = 1024,
    parameter TRIT_SIZE = 4
  ) (
    /* clock  and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with instruction median. */
    output logic instruction_pointer_out; // pointer to the instruction we want in memory
    input wire [INSTRUCTION_SIZE-1:0] instruction_in, // the instruction from the instruction median
    // There is only one half of the ready/valid communication because we assume that instruction_pointer_out is always valid
    // and the instruction median is always ready.
    input wire instruction_valid, // instruction_in is now a valid instruction!
    output logic instruction_ready, // tell the program counter that we are ready for a new instruction

    /* communication with data median. */
    output logic [DATA_LENGTH-1:0] data_pointer_out; // tell the data median what data to extract
    input wire [X_SIZE-1:0] data_x_in; // x value of data at the above pointer address
    input wire [X_SIZE-1:0] data_y_in; // y value of data at the above pointer address
    // There are no other ready/valid signals because everything else is always valid and ready
    input wire data_in_valid;

    /* communication with weight median. */
    output logic [WEIGHT_LENGTH-1:0] weight_pointer_out, // tell the weight median what weight to extract
    input wire [W_SIZE-1:0] weight_in, // input from the weight median
    output logic [W_SIZE-1:0] weight_out, // output to the weight median
    // No ready signal for weight_in because the cpu is always ready to receive when it asks for an input
    input wire weight_in_valid,
    input wire weight_out_ready,
    output logic weight_out_valid,

    /* communication with the stack */
    input wire [X_SIZE-1:0] stack_in, // the top of the stack
    output logic [X_SIZE-1:0] stack_out, // value to push to the top of the stack
    input wire stack_out_ready, // is the stack ready to be pushed to? this is probably usually true
    input wire stack_in_valid, // has the stack finished reading from the top? this is probably usually true
    output logic stack_in_ready, // is the CPU ready to receive from stack_in? This is only used so that the stack knows to drop the value on top
    output logic stack_out_valid, // Does the CPU want to push a value on top of the stack?
    
  );

  localparam IP_SIZE = $clog2(PROGRAM_LENGTH-1);
  localparam D_SIZE = $clog2(DATA_LENGTH-1);
  localparam A_SIZE = $clog2(WEIGHT_LENGTH-1);

  /* Pointers */
  logic [IP_SIZE-1:0] instruction_pointer = 0;
  logic [D_SIZE-1:0] data_pointer = 0;
  assign data_poointer_out = data_pointer;
  logic [A_SIZE-1:0] weight_pointer = 0;
  assign weight_pointer_out = weight_pointer;

  /* Registers */
  logic [X_SIZE-1:0] x_register = 0;
  logic [X_SIZE-1:0] y_register = 0;
  logic [W_SIZE-1:0] w_register = 0;
  logic [W_SIZE-1:0] grad_register = 0;
  logic [TRIT_SIZE-1:0] trit = 0;

  /* The neural net blocks */
  logic [X_SIZE-1:0] interweave_y;
  interweave #(
      .X_SIZE(X_SIZE),
      .W_SIZE(W_SIZE),
      .TRIT_SIZE(TRIT_SIZE)
    ) interweave_block (
      .x(x_register),
      .w(w_register),
      .trit(trit),
      .y(interweave_y)
  );

  logic [X_SIZE-1:0] binterweave_x;
  logic [W_SIZE-1:0] binterweave_grad;
  binterweave #(
      .X_SIZE(X_SIZE),
      .W_SIZE(W_SIZE),
      .TRIT_SIZE(TRIT_SIZE)
    ) binterweave_block (
      .y(y_register),
      .w(w_register),
      .trit(trit),
      .x(binterweave_x),
      .grad(binterweave_grad)
  );

  logic [W_SIZE-1:0] stoch_grad_out;
  binterweave #(
      .W_SIZE(W_SIZE)
  ) stoch_grad_block (
      .flip_weight_in(grad_register),
      .flip_weight_out(stoch_grad_out)
  );

  /* The instruction set in more readable terms */
  localparam SET_TRIT_TO_0 = 0; // "TRIT = 0"
  localparam SET_TRIT_TO_1 = 1; // "TRIT = 1"
  localparam SET_TRIT_TO_2 = 2; // "TRIT = 2"
  localparam SET_TRIT_TO_3 = 3; // "TRIT = 3"
  localparam SET_TRIT_TO_4 = 4; // "TRIT = 4"
  localparam SET_TRIT_TO_5 = 5; // "TRIT = 5"
  localparam SET_TRIT_TO_6 = 6; // "TRIT = 6"
  localparam SET_TRIT_TO_7 = 7; // "TRIT = 7"
  localparam SET_TRIT_TO_8 = 8; // "TRIT = 8"
  localparam SET_TRIT_TO_9 = 9; // "TRIT = 9"
  localparam SET_TRIT_TO_10 = 10; // "TRIT = 10"
  localparam SET_TRIT_TO_11 = 11; // "TRIT = 11"
  localparam SET_TRIT_TO_12 = 12; // "TRIT = 12"
  localparam SET_TRIT_TO_13 = 13; // "TRIT = 13"
  localparam SET_TRIT_TO_14 = 14; // "TRIT = 14"
  localparam SET_TRIT_TO_15 = 15; // "TRIT = 15"
  localparam SET_I_TO_0 = 16; // "I = 0"
  localparam D_INCREMNT = 17; // "D++"
  localparam D_DECREMNT = 18; // "D--"
  localparam A_INCREMNT = 19; // "A++"
  localparam A_DECREMNT = 20; // "A--"
  localparam SET_X_TO_VALUE_AT_D0 = 21; // "X = *D0"
  localparam SET_Y_TO_VALUE_AT_D1 = 22; // "Y = *D1"
  localparam SET_XY_TO_VALUE_AT_D = 23; // "X, Y = *D"
  localparam SET_W_TO_VALUE_AT_A = 24; // "W = *A"
  localparam SET_VALUE_AT_A_TO_W = 25; // "*A = W"
  localparam SWAP_XY = 26; // "X, Y = Y, X"
  localparam SET_X_TO_Y = 27; // "X = Y"
  localparam SET_Y_TO_X = 28; // "Y = X"
  localparam PUSH_X = 29; // "PUSH X"
  localparam PUSH_Y = 30; // "PUSH Y"
  localparam POP_X = 31; // "POP X"
  localparam POP_Y = 32; // "POP Y"
  localparam SET_X_TO_X_XOR_Y = 33; // "X = X ^ Y"
  localparam SET_Y_TO_X_XOR_Y = 34; // "Y = X ^ Y"
  localparam SET_X_TO_X_AND_Y = 35; // "X = X & Y"
  localparam SET_Y_TO_X_AND_Y = 36; // "Y = X & Y"
  localparam SET_X_TO_X_OR_Y = 37; // "X = X | Y"
  localparam SET_Y_TO_X_OR_Y = 38; // "Y = X | Y"
  localparam INTERWEAVE = 39; // "INTERWEAVE"
  localparam BACKPROP = 40; // "BACKPROP"
  localparam STOCH_GRAD = 41; // "STOCH GRAD"

  /* current instruction we are working on */
  logic [INSTRUCTION_SIZE-1:0] instruction = SET_I_TO_0;
  /* ready for the next instruction */
  logic ready = 1;
  // Note that this is just the same as the output wire:
  assign instruction_ready = ready;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      instruction_pointer = 0;
      data_pointer = 0;
      weight_pointer = 0;

      x_register = 0;
      y_register = 0;
      w_register = 0;
      grad_register = 0;
      trit = 0;

      instruction = SET_I_TO_0;
      ready = 1;
    end else if (ready) begin
      instruction <= instruction_in;

      /* Break up the different instructions into groups of cases. This is to make the code more readable. */

      /* logic for SET_TRIT_TO_i */
      case(instruction_in)
        SET_TRIT_TO_0: begin
          trit <= 0;
          ready <= 1;
        end
        SET_TRIT_TO_1: begin
          trit <= 1;
          ready <= 1;
        end
        SET_TRIT_TO_2: begin
          trit <= 2;
          ready <= 1;
        end
        SET_TRIT_TO_3: begin
          trit <= 3;
          ready <= 1;
        end
        SET_TRIT_TO_4: begin
          trit <= 4;
          ready <= 1;
        end
        SET_TRIT_TO_5: begin
          trit <= 5;
          ready <= 1;
        end
        SET_TRIT_TO_6: begin
          trit <= 6;
          ready <= 1;
        end
        SET_TRIT_TO_7: begin
          trit <= 7;
          ready <= 1;
        end
        SET_TRIT_TO_8: begin
          trit <= 8;
          ready <= 1;
        end
        SET_TRIT_TO_9: begin
          trit <= 9;
          ready <= 1;
        end
        SET_TRIT_TO_10: begin
          trit <= 10;
          ready <= 1;
        end
        SET_TRIT_TO_11: begin
          trit <= 11;
          ready <= 1;
        end
        SET_TRIT_TO_12: begin
          trit <= 12;
          ready <= 1;
        end
        SET_TRIT_TO_13: begin
          trit <= 13;
          ready <= 1;
        end
        SET_TRIT_TO_14: begin
          trit <= 14;
          ready <= 1;
        end
        SET_TRIT_TO_15: begin
          trit <= 15;
          ready <= 1;
        end
        default: begin
          // do nothing
        end
      endcase

      /* logic for incrementing pointer/setting it to 0 */
      case(instruction_in)
        SET_I_TO_0: begin
          instruction_pointer <= 0;
          ready <= 1;
        end
        default: begin
          instruction_pointer <= instruction_pointer + 1; // increment pointer
        end
      endcase

      /* logic for incrementing/decrementing other pointers */
      case(instruction_in)
        D_INCREMNT: begin
          data_pointer <= (data_pointer == (DATA_LENGTH - 1))? 0 : data_pointer + 1; // increment by 1, rolling over if too large
          ready <= 1;
        end
        D_DECREMNT: begin
          data_pointer <= (data_pointer == 0)? (DATA_LENGTH - 1) : data_pointer - 1; // decrement by 1, rolling over if too small
          ready <= 1;
        end
        A_INCREMNT: begin
          weight_pointer <= (weight_pointer == (WEIGHT_LENGTH - 1))? 0 : weight_pointer + 1; // increment by 1, rolling over if too large
          ready <= 1;
        end
        A_DECREMNT: begin
          weight_pointer <= (weight_pointer == 0)? (WEIGHT_LENGTH - 1) : weight_pointer - 1; // decrement by 1, rolling over if too small
          ready <= 1;
        end
        default: begin
          // do nothing
        end
      endcase

      /* Transferring data and weights to/from BRAM. These instructions can take multiple clock cycles. */
      case(instruction_in)
        SET_X_TO_VALUE_AT_D0: begin
          x_register <= data_x_in;
          ready <= data_in_valid;
        end
        SET_Y_TO_VALUE_AT_D1: begin
          y_register <= data_y_in;
          ready <= data_in_valid;
        end
        SET_XY_TO_VALUE_AT_D: begin
          x_register <= data_x_in;
          y_register <= data_y_in;
          ready <= data_in_valid;
        end
        SET_W_TO_VALUE_AT_A: begin
          w_register <= weight_in;
          ready <= weight_in_valid;
        end
        SET_VALUE_AT_A_TO_W: begin
          weight_out <= weight_out_ready? w_register : weight_out;
          ready <= weight_out_ready;
        end
        default: begin
          // do nothing
        end
      endcase

      /* Operations between registers */
      case(instruction_in)
        SWAP_XY: begin
          x_register <= y_register;
          y_register <= x_register;
          ready <= 1;
        end
        SET_X_TO_Y: begin
          x_register <= y_register;
          ready <= 1;
        end
        SET_Y_TO_X: begin
          y_register <= x_register;
          ready <= 1;
        end
        SET_X_TO_X_XOR_Y: begin
          x_register <= x_register ^ y_register;
          ready <= 1;
        end
        SET_Y_TO_X_XOR_Y: begin
          y_register <= x_register ^ y_register;
          ready <= 1;
        end
        SET_X_TO_X_AND_Y: begin
          x_register <= x_register & y_register;
          ready <= 1;
        end
        SET_Y_TO_X_AND_Y: begin
          y_register <= x_register & y_register;
          ready <= 1;
        end
        SET_X_TO_X_OR_Y: begin
          x_register <= x_register | y_register;
          ready <= 1;
        end
        SET_Y_TO_X_OR_Y: begin
          y_register <= x_register | y_register;
          ready <= 1;
        end
        default: begin
          // do nothing
        end
      endcase

      /* Pushing to the stack */
      case(instruction_in)
        PUSH_X: begin
          stack_out <= x_register;
          stack_out_valid <= 1;
          ready <= stack_out_ready;
        end
        PUSH_Y: begin
          stack_out <= y_register;
          stack_out_valid <= 1;
          ready <= stack_out_ready;
        end
        default: begin
          stack_out_valid <= 0;
        end
      endcase

      /* Popping from the stack */
      case(instruction_in)
        POP_X: begin
          x_register <= stack_in;
          stack_in_ready <= 1;
          ready <= stack_in_valid;
        end
        POP_Y: begin
          y_register <= stack_in;
          stack_in_ready <= 1;
          ready <= stack_in_valid;
        end
        default: begin
          stack_in_ready <= 0;
        end
      endcase

      /* The most important instructions!!! These are the neural network operations */
      case(instruction_in)
        INTERWEAVE: begin
          y_register <= interweave_y;
          ready <= 1;
        end
        BACKPROP: begin
          x_register <= binterweave_x;
          grad_register <= binterweave_grad;
          ready <= 1;
        end
        STOCH_GRAD: begin
          w_register <= w_register ^ stoch_grad_out;
          ready <= 1;
        end
        default: begin
          // do nothing
        end
      endcase
    end else begin // what do we do if we're not ready for a new operation?
      // Only some operations take more than one clock cycle:

      /* Transferring data and weights to/from BRAM. These instructions can take multiple clock cycles. */
      case(instruction)
        SET_X_TO_VALUE_AT_D0: begin
          x_register <= data_x_in;
          ready <= data_in_valid;
        end
        SET_Y_TO_VALUE_AT_D1: begin
          y_register <= data_y_in;
          ready <= data_in_valid;
        end
        SET_XY_TO_VALUE_AT_D: begin
          x_register <= data_x_in;
          y_register <= data_y_in;
          ready <= data_in_valid;
        end
        SET_W_TO_VALUE_AT_A: begin
          w_register <= weight_in;
          ready <= weight_in_valid;
        end
        SET_VALUE_AT_A_TO_W: begin
          weight_out <= weight_out_ready? w_register : weight_out;
          ready <= weight_out_ready;
        end
        default: begin
          // do nothing
        end
      endcase

      /* Pushing to the stack */
      case(instruction)
        PUSH_X: begin
          stack_out <= x_register;
          stack_out_valid <= 1;
          ready <= stack_out_ready;
        end
        PUSH_Y: begin
          stack_out <= y_register;
          stack_out_valid <= 1;
          ready <= stack_out_ready;
        end
        default: begin
          stack_out_valid <= 0;
        end
      endcase

      /* Popping from the stack */
      case(instruction)
        POP_X: begin
          x_register <= stack_in;
          stack_in_ready <= 1;
          ready <= stack_in_valid;
        end
        POP_Y: begin
          y_register <= stack_in;
          stack_in_ready <= 1;
          ready <= stack_in_valid;
        end
        default: begin
          stack_in_ready <= 0;
        end
      endcase
    end
  end


endmodule; // cpu
`default_nettype wire