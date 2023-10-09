`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module unit (
    input wire rst_in,
    input wire clk_in,
    input wire fd_prop,
    input wire bk_prop,
    input wire fin1,
    input wire fin2,
    input wire fin3,
    input wire bin1,
    input wire bin2,
    input wire bin3,
    output logic fout1,
    output logic fout2,
    output logic fout3,
    output logic bout1,
    output logic bout2,
    output logic bout3,
  );

  logic control;

  logic bcontrol;
  logic switch_control;

  logic new_fout1;
  logic new_fout2;
  logic new_fout3;
  logic new_bout1;
  logic new_bout2;
  logic new_bout3;
  logic new_bcontrol;

  perceptron perc_gate(
    .fcontrol(control),
    .fin1(fin1),
    .fin2(fin2),
    .fin3(fin3),
    .bin1(bin1),
    .bin2(bin2),
    .bin3(bin3),
    .fout1(new_fout1),
    .fout2(new_fout2),
    .fout3(new_fout3),
    .bcontrol(new_bcontrol),
    .bout1(new_bout1),
    .bout2(new_bout2),
    .bout3(new_bout3)
  )

  accum grad_accumulator(
    .rst_in(rst_in),
    .clk_in(clk_in),
    .prop_in(bk_prop),
    .inc(bcontrol),
    .trigger(switch_control)
  )

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      fout1 <= 0;
      fout2 <= 0;
      fout3 <= 0;
      bout1 <= 0;
      bout2 <= 0;
      bout3 <= 0;
      control <= 0;
    end else begin
      if (fd_prop) begin
        fout1 <= new_fout1;
        fout2 <= new_fout2;
        fout3 <= new_fout3;
      end
      if (bk_prop) begin
        bout1 <= new_bout1;
        bout2 <= new_bout2;
        bout3 <= new_bout3;
        bcontrol <= new_bcontrol;
      end
      if (switch_control) begin
        control <= ~control;
      end
    end
  end

endmodule // perceptron
`default_nettype wire