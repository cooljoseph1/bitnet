`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module down3 #(
    parameter N = 27
 )
 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop, // signal to start forward propagation
    input wire bk_prop, // signal to start backward propagation

    input wire [N-1:0] fin,
    input wire [((N+2)/3)-1:0] bin,

    output logic fd_prop_done, // signal that the forward propagation is done
    output logic bk_prop_done, // signal that the backward propagation is done
    output logic [((N+2)/3)-1:0] control_out,  // to get the saved weights

    output logic [((N+2)/3)-1:0] fout,
    output logic [N-1:0] bout
  );
  localparam OUT_N = (N + 2) / 3;
  localparam PADDED_N = OUT_N * 3;
  localparam PADDING = PADDED_N - N;
  
  logic [PADDED_N-1:0] padded_fin;
  assign padded_fin[N-1:0] = fin;

  logic [PADDED_N-1:0] padded_bout;
  assign bout = padded_bout[N-1:0];

  generate
    if (PADDED_N == 1) begin
      assign padded_fin[PADDED_N-1] = 0;
    end else if (PADDED_N == 2) begin
      assign padded_fin[PADDED_N-1] = 0;
      assign padded_fin[PADDED_N-2] = 1;
    end
  endgenerate

  genvar i;
  generate
    for (i = 0; 3 * i < (PADDED_N - 2); i = i + 1) begin
      unit3to1 down_unit(
        .rst_in(rst_in),
        .clk_in(clk_in),
        .oscillator(oscillator),
        .fd_prop(fd_prop),
        .bk_prop(bk_prop),
        .fin(padded_fin[3 * i + 2:3 * i]),
        .bin(bin[i]),
        .fout(fout[i]),
        .bout(padded_bout[3 * i + 2:3 * i]),
        .control_out(control_out[i])
      );
    end
  endgenerate

  signal_delay fd_done(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .in_signal(fd_prop),
    .out_signal(fd_prop_done)
  );
  
  signal_delay bk_done(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .in_signal(bk_prop),
    .out_signal(bk_prop_done)
  );

endmodule // down3
`default_nettype wire