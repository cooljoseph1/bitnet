`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module signal_delay #(parameter N = 1)
(
    input wire clk_in,         // Clock input
    input wire rst_in,         // Reset input
    input wire in_signal,  // Input signal to be delayed
    output logic out_signal // Delayed output signal
);

    reg [N-1:0] shift_register; // Shift register to store delayed values

    always @(posedge clk_in)
    begin
        if (rst_in)
            shift_register <= {N{1'b0}}; // Reset the shift register to all zeros
        else if (N>1)
            shift_register <= {shift_register[N-2:0], in_signal}; // Shift in the input signal
        else
            shift_register <= in_signal;
    end

    assign out_signal = shift_register[N-1]; // Output the delayed signal

endmodule // signal_delay
`default_nettype wire