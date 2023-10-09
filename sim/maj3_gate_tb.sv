`timescale 1ns / 1ps
`default_nettype none

module maj3_gate_tb();
  logic control;
  logic [2:0] in;
  logic out;

  maj3_gate test_maj(
    .control(control),
    .in(in),
    .out(out)
  );

  initial begin
    $display("\n--------\nStarting Simulation!");

    {control, in} = 4'b1000;
    #5
    $display(out);

    #5
    {control, in} = 4'b0100;
    #5
    $display(out);

    #5
    {control, in} = 4'b0110;
    #5
    $display(out);

    #5
    {control, in} = 4'b1101;
    #5
    $display(out);
    $finish;
  end
endmodule // maj3_gate_tb