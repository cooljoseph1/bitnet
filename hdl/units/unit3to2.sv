`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit3to2 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop,
    input wire bk_prop,

    input wire [2:0] fin,
    input wire [1:0] bin,

    output logic control_out, // to get the saved weight

    output logic [1:0] fout,
    output logic [2:0] bout
  );

  logic control;
  assign control_out = control;

  logic bcontrol;
  logic switch_control;

  logic [1:0] new_fout;
  logic [2:0] new_bout;
  logic new_bcontrol;

  p3to2 perc_gate(
    .oscillator(oscillator),
    .fcontrol(control),
    .fin(fin),
    .bin(bin),
    .fout(new_fout),
    .bcontrol(new_bcontrol),
    .bout(new_bout)
  );

  accum grad_accumulator(
    .rst_in(rst_in),
    .clk_in(clk_in),
    .prop_in(bk_prop),
    .inc(bcontrol),
    .trigger(switch_control)
  );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      fout <= 2'b00;
      bout <= 3'b000;
      control <= oscillator;
    end else begin
      if (fd_prop) begin
        fout <= new_fout;
      end
      if (bk_prop) begin
        bout <= new_bout;
        bcontrol <= new_bcontrol;
      end
      if (switch_control) begin
        control <= ~control;
      end
    end
  end

endmodule // unit3to2
`default_nettype wire