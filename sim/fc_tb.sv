`timescale 1ns / 1ps
`default_nettype none

module fc_tb();
  logic rst_in = 0;
  logic clk_in = 0;
  logic oscillator = 0;
  logic fd_prop;
  logic bk_prop;
  logic [8:0] fin;
  logic [8:0] bin;
  logic [8:0] fout;
  logic [8:0] bout;
  logic [8:0] control_out [0:1];

  fc #(.N(9)) test_fc(
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
    $display("\n--------\nStarting Simulation!");

    fin = 9'b111000111;
    fd_prop = 0;
    bk_prop = 0;
    rst_in = 1;
    #10
    rst_in = 0;
    fd_prop = 1;
    #10

    #1000
    $display("%b", fout);
    $display("%b", control_out[0]);
    $finish;
  end
endmodule // fc_tb