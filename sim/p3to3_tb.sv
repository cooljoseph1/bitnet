`timescale 1ns / 1ps
`default_nettype none

module p3to3_tb();
    logic fcontrol;
    logic [2:0] fin;
    logic [2:0] bin;
    logic [2:0] fout;
    logic bcontrol;
    logic [2:0] bout;

  p3to3 test_p3to3(
    .fcontrol(fcontrol),
    .fin(fin),
    .bin(bin),
    .fout(fout),
    .bcontrol(bcontrol),
    .bout(bout)
  );

  initial begin
    $display("\n--------\nStarting Simulation!");

    #5
    {fcontrol, fin} = 4'b1000;
    #5
    $display("%b", fout);

    #5
    {fcontrol, fin} = 4'b0010;
    #5
    $display("%b", fout);

    #5
    bin = 3'b110;
    #5
    $display("%b", {bout, bcontrol});

    $finish;
  end
endmodule // p3to3_tb