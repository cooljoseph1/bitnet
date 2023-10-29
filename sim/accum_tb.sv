`timescale 1ns / 1ps
`default_nettype none

module accum_tb();
    logic clk_in;
    logic rst_in;
    logic prop_in;
    logic inc;
    logic trigger;

  accum #(
    .THRESHOLD(31)
  ) test_accum (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .prop_in(prop_in),
    .inc(inc),
    .trigger(trigger)
  );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("accum.vcd"); //file to store value change dump (vcd)
    $dumpvars(1,test_accum);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;
    prop_in = 0;

    #10
    rst_in = 0;
    prop_in = 1;
    inc = 0;

    for (int i=0; i < 1000; i=i+1)begin
        #10
        inc = (i % 10 < 7);
    end

    $finish;
  end
endmodule // accum_tb