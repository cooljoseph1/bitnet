module cpu #(
    parameter PROGRAM_LENGTH = 256,
    parameter DATA_LENGTH = 256,
    parameter WEIGHT_LENGTH = 256,
    parameter HEAP_LENGTH = 256,
    parameter INSTRUCTION_SIZE = 16,
    parameter X_SIZE = 1024,
    parameter W_SIZE = 1024,
    parameter TRIT_SIZE = 4
  ) (
    /* clock  and reset */
    input wire clk_in,
    input wire rst_in,

    output logic [X_SIZE-1:0] inference_out,
    output logic inference_valid_out,

    /* communication with instruction medium. */
    output logic [I_SIZE-1:0] instruction_addr_out, // pointer to the instruction we want in memory
    output logic instruction_ready_out,
    input wire [INSTRUCTION_SIZE-1:0] instruction_in, // the instruction from the instruction medium
    input wire instruction_valid_in,
    
    /* communication with data medium. */
    output logic [D_SIZE-1:0] data_addr_out, // tell the data medium where to read
    output logic data_read_enable_out,
    input wire [X_SIZE-1:0] data_x_in, // x value of data at the above pointer address
    input wire [X_SIZE-1:0] data_y_in, // y value of data at the above pointer address
    // There are no other ready/valid signals because everything else is always valid and ready
    input wire data_medium_finished_in,

    /* communication with weight medium. */
    output logic [A_SIZE-1:0] weight_addr_out, // tell the weight medium where to read/write
    input wire [W_SIZE-1:0] weight_in, // input from the weight medium
    output logic [W_SIZE-1:0] weight_out, // output to the weight medium
    output logic weight_read_enable_out,
    output logic weight_write_enable_out,
    input wire weight_medium_finished_in,

    /* communication with heap medium. */
    output logic [H_SIZE-1:0] heap_addr_out, // tell the heap medium where to read/write
    input wire [X_SIZE-1:0] heap_in, // input from the heap medium
    output logic [X_SIZE-1:0] heap_out, // output to the heap medium
    output logic heap_read_enable_out,
    output logic heap_write_enable_out,
    input wire heap_medium_finished_in
  );

  localparam I_SIZE = $clog2(PROGRAM_LENGTH);
  localparam D_SIZE = $clog2(DATA_LENGTH);
  localparam A_SIZE = $clog2(WEIGHT_LENGTH);
  localparam H_SIZE = $clog2(HEAP_LENGTH);

  /* Pointers */
  logic [I_SIZE-1:0] instruction_pointer = 0;
  assign instruction_addr_out = instruction_pointer;
  logic [D_SIZE-1:0] data_pointer = 0;
  assign data_addr_out = data_pointer;
  logic [A_SIZE-1:0] weight_pointer = 0;
  assign weight_addr_out = weight_pointer;
  logic [H_SIZE-1:0] heap_pointer = 0;
  assign heap_addr_out = heap_pointer;

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
  stoch_grad #(
      .W_SIZE(W_SIZE)
  ) stoch_grad_block (
      .flip_weight_in(grad_register),
      .flip_weight_out(stoch_grad_out)
  );

  /* The instruction set in more readable terms */
  /* ----- PYTHON PARSING BEGINS HERE ----- */
  localparam SET_I_TO_0 = 0; // "I = 0"
  localparam SET_TRIT_TO_NEXT_VALUE = 1; // "TRIT = NEXT"
  localparam SET_H_TO_NEXT_VALUE = 2; // "H = NEXT"
  localparam D_INCREMENT = 3; // "D++"
  localparam D_DECREMENT = 4; // "D--"
  localparam A_INCREMENT = 5; // "A++"
  localparam A_DECREMENT = 6; // "A--"
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
  /* ----- PYTHON PARSING ENDS HERE ----- */

  /* current instruction we are working on */
  logic [INSTRUCTION_SIZE-1:0] instruction = SET_I_TO_0;
  /* ready for the next instruction */
  logic ready = 1;

  logic [2:0] code; // what kind of operation is it?
  logic [12:0] value; // subcodes and values for the set operations

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      instruction_pointer <= 0;
      data_pointer <= 0;
      weight_pointer <= 0;
      heap_pointer <= 0;

      x_register <= 0;
      y_register <= 0;
      w_register <= 0;
      grad_register <= 0;
      trit <= 0;

      instruction <= SET_I_TO_0;
      ready <= 1;
    end else if (ready) begin
      instruction_ready_out <= 1'b1;
      if (instruction_valid_in) begin
        instruction <= instruction_in;

        /* Break up the different instructions into groups of cases. This is to make the code more readable. */

        /* logic for incrementing pointer/setting it to 0, including whether the next instruction should be read into trit or heap pointer */
        case(instruction_in)
          SET_I_TO_0: begin
            instruction_pointer <= 0;
            ready <= 1;
          end
          SET_TRIT_TO_NEXT_VALUE: begin
            instruction_pointer <= instruction_pointer + 1;
            ready <= 0;
          end
          SET_H_TO_NEXT_VALUE: begin
            instruction_pointer <= instruction_pointer + 1;
            ready <= 0;
          end
          default: begin
            instruction_pointer <= instruction_pointer + 1; // increment pointer for everything else
          end
        endcase

        /* logic for incrementing/decrementing other pointers */
        case(instruction_in)
          D_INCREMENT: begin
            data_pointer <= (data_pointer == (DATA_LENGTH - 1))? 0 : data_pointer + 1; // increment by 1, rolling over if too large
            ready <= 1;
          end
          D_DECREMENT: begin
            data_pointer <= (data_pointer == 0)? (DATA_LENGTH - 1) : data_pointer - 1; // decrement by 1, rolling over if too small
            ready <= 1;
          end
          A_INCREMENT: begin
            weight_pointer <= (weight_pointer == (WEIGHT_LENGTH - 1))? 0 : weight_pointer + 1; // increment by 1, rolling over if too large
            ready <= 1;
          end
          A_DECREMENT: begin
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
            data_read_enable_out <= 1'b1;
            ready <= 1'b0;
          end
          SET_Y_TO_VALUE_AT_D1: begin
            y_register <= data_y_in;
            data_read_enable_out <= 1'b1;
            ready <= 1'b0;
          end
          SET_XY_TO_VALUE_AT_D: begin
            x_register <= data_x_in;
            y_register <= data_y_in;
            data_read_enable_out <= 1'b1;
            ready <= 1'b0;
          end
          SET_W_TO_VALUE_AT_A: begin
            w_register <= weight_in;
            weight_read_enable_out <= 1'b1;
            ready <= 0;
          end
          SET_VALUE_AT_A_TO_W: begin
            weight_out <= w_register;
            weight_write_enable_out <= 1'b1;
            ready <= 0;
          end
          SET_X_TO_VALUE_AT_H: begin
            x_register <= heap_in;
            heap_read_enable_out <= 1'b1;
            ready <= 0;
          end
          SET_VALUE_AT_H_TO_X: begin
            heap_out <= x_register;
            heap_write_enable_out <= 1'b1;
            ready <= 0;
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

        case(instruction_in)
          SET_INFERENCE_TO_Y: begin
            inference_out <= y_register;
            inference_valid_out <= 1;
            ready <= 1;
          end
          default: begin
            inference_valid_out <= 0;
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
      end
    end else begin // what do we do if we're not ready for a new operation?
      instruction_ready_out <= 1'b0;
      // Only some operations take more than one clock cycle:

      case(instruction)
        SET_TRIT_TO_NEXT_VALUE: begin
          trit <= instruction_in;
          ready <= instruction_valid_in;
          instruction_pointer <= instruction_valid_in? instruction_pointer + 1 : instruction_pointer;
        end
        SET_H_TO_NEXT_VALUE: begin
          heap_pointer <= instruction_in;
          ready <= instruction_valid_in;
          instruction_pointer <= instruction_valid_in? instruction_pointer + 1 : instruction_pointer;
        end
        default: begin
          // do nothing
        end
      endcase

      /* Transferring data and weights to/from BRAM. These instructions can take multiple clock cycles. */
      case(instruction)
        SET_X_TO_VALUE_AT_D0: begin
          x_register <= data_x_in;
          data_read_enable_out <= 1'b0;
          ready <= data_medium_finished_in;
        end
        SET_Y_TO_VALUE_AT_D1: begin
          y_register <= data_y_in;
          data_read_enable_out <= 1'b0;
          ready <= data_medium_finished_in;
        end
        SET_XY_TO_VALUE_AT_D: begin
          x_register <= data_x_in;
          y_register <= data_y_in;
          data_read_enable_out <= 1'b0;
          ready <= data_medium_finished_in;
        end
        SET_W_TO_VALUE_AT_A: begin
          w_register <= weight_in;
          weight_read_enable_out <= 1'b0;
          ready <= weight_medium_finished_in;
        end
        SET_VALUE_AT_A_TO_W: begin
          weight_write_enable_out <= 1'b0;
          ready <= weight_medium_finished_in;
        end
        SET_X_TO_VALUE_AT_H: begin
          x_register <= heap_in;
          heap_read_enable_out <= 1'b0;
          ready <= heap_medium_finished_in;
        end
        SET_VALUE_AT_H_TO_X: begin
          heap_write_enable_out <= 1'b0;
          ready <= heap_medium_finished_in;
        end
        default: begin
          // do nothing
        end
      endcase
    end
  end


endmodule // cpu