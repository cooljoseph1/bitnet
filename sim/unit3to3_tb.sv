`timescale 1ns / 1ps
`default_nettype none

module unit3to3_tb();
  logic rst_in = 0;
  logic clk_in = 0;
  logic oscillator = 0;
  logic fd_prop;
  logic bk_prop;
  logic [2:0] fin;
  logic [2:0] bin;
  logic [2:0] fout;
  logic [2:0] bout;
  logic control_out;

  unit3to3 test_unit3to3(
    .rst_in(rst_in),
    .clk_in(clk_in),
    .oscillator(oscillator),
    .fd_prop(fd_prop),
    .bk_prop(bk_prop),
    .fin(fin),
    .bin(bin),
    .fout(fout),
    .bout(bout),
    .control_out(control_out)
  );

  always begin
      #3;
      oscillator = !oscillator;
  end

  always begin
      #5;
      clk_in = !clk_in;
  end

  assign bin = ~fin ^ fout;
  
  initial begin
    $dumpfile("unit3to3.vcd"); //file to store value change dump (vcd)
    $dumpvars(1,test_unit3to3);
    $display("\n--------\nStarting Simulation!");
    fin = 3'b111;
    fd_prop = 0;
    bk_prop = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    fd_prop = 1;

    #1000
    $display("%b", fout);
    $display("%b", control_out);
    $finish;
  end
endmodule // fc_tb