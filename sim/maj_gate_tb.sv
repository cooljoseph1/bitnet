`timescale 1ns / 1ps
`default_nettype none

module maj_gate_tb();
  logic control;
  logic in0;
  logic in1;
  logic in2;
  logic out;

  maj_gate test_maj(
    .control(control),
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .out(out)
  );

  initial begin
    $display("\n--------\nStarting Simulation!");

    {control, in0, in1, in2} = 4'b1000;
    #5
    $display(out);

    #5
    {control, in0, in1, in2} = 4'b0100;
    #5
    $display(out);

    #5
    {control, in0, in1, in2} = 4'b0110;
    #5
    $display(out);

    #5
    {control, in0, in1, in2} = 4'b1101;
    #5
    $display(out);
    $finish;
  end
endmodule // maj_gate_tb