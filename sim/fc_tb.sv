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
  logic [1:0][2:0] control_out;

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
      #10;
      oscillator = !oscillator;
  end

  always begin
      #5;
      clk_in = !clk_in;
  end

  assign bin = ~fin ^ fout;
  
  initial begin
    $dumpfile("fc.vcd"); //file to store value change dump (vcd)
    $dumpvars(1,test_fc);
    $display("\n--------\nStarting Simulation!");
    fin = 9'b010000110;
    fd_prop = 0;
    bk_prop = 0;
    rst_in = 1;
    #10;
    rst_in = 0;

    bk_prop = 0;
    fd_prop = 1;
    #30;
    fd_prop = 0;
    bk_prop = 1;
    #30;

    $display("BEGINNING VALUES");
    $display("%b", fin);
    $display("%b", fout);
    $display("%b", bin);
    $display("%b", bout);
    $display("%b", control_out[0]);
    $display("%b", control_out[1]);

    for(int i = 0; i < 10000; i = i + 1) begin
      bk_prop = 0;
      fd_prop = 1;
      #30;
      fd_prop = 0;
      bk_prop = 1;
      #30;
    end
    $display("ENDING VALUES");
    $display("%b", fin);
    $display("%b", fout);
    $display("%b", bin);
    $display("%b", bout);
    $display("%b", control_out[0]);
    $display("%b", control_out[1]);

    fd_prop = 0;
    bk_prop = 1;
    #1000
    $display("%b", bout);
    $display("%b", control_out[0]);
    $display("%b", control_out[1]);

    $finish;
  end
endmodule // fc_tb