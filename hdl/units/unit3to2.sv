`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit3to2 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop,
    input wire bk_prop,
    input wire fin0,
    input wire fin1,
    input wire fin2,
    input wire bin0,
    input wire bin1,
    output logic fout0,
    output logic fout1,
    output logic bout0,
    output logic bout1,
    output logic bout2,
    output logic control_out // to get the saved weight
  );

  logic control;
  assign control_out = control;

  logic bcontrol;
  logic switch_control;

  logic new_fout0;
  logic new_fout1;
  logic new_bout0;
  logic new_bout1;
  logic new_bout2;
  logic new_bcontrol;

  p3to2 perc_gate(
    .oscillator(oscillator),
    .fcontrol(control),
    .fin0(fin0),
    .fin1(fin1),
    .fin2(fin2),
    .bin0(bin0),
    .bin1(bin1),
    .fout0(new_fout0),
    .fout1(new_fout1),
    .bcontrol(new_bcontrol),
    .bout0(new_bout0),
    .bout1(new_bout1),
    .bout2(new_bout2)
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
      fout0 <= 0;
      fout1 <= 0;
      fout2 <= 0;
      bout0 <= 0;
      bout1 <= 0;
      bout2 <= 0;
      control <= 0;
    end else begin
      if (fd_prop) begin
        fout0 <= new_fout0;
        fout1 <= new_fout1;
        fout2 <= new_fout2;
      end
      if (bk_prop) begin
        bout0 <= new_bout0;
        bout1 <= new_bout1;
        bout2 <= new_bout2;
        bcontrol <= new_bcontrol;
      end
      if (switch_control) begin
        control <= ~control;
      end
    end
  end

endmodule // unit3to2
`default_nettype wire