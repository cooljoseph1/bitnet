`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module control_unit (
    /* For data transfer into the control unit from the RAM */
    input wire x_in,
    input wire y_in,

    /* For talking with the neural network peripheral */
    output logic x_out_nn, // values to run through the forward/backward pass
    output logic control_unit_to_neural_net_valid, // signal to the neural net that we have new data (i.e. x_out_nn) for it to process
    input wire neural_net_to_control_unit_ready, // signal from the neural net that it is ready for more data
    input wire y_in_nn, // result of running through the forward/backward pass
    input wire neural_net_to_control_unit_valid, // signal from the neural net that it's output (i.e. y_in_nn) is now valid
    output logic control_unit_to_neural_net_ready, // signal to the neural net that we are ready to receive new data. Should always be high?
  );

  

endmodule // unit3to3
`default_nettype wire