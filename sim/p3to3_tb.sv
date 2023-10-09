`timescale 1ns / 1ps
`default_nettype none

module p3to3_tb();
    logic fcontrol;
    logic fin0;
    logic fin1;
    logic fin2;
    logic bin0;
    logic bin1;
    logic bin2;
    logic fout0;
    logic fout1;
    logic fout2;
    logic bcontrol;
    logic bout0;
    logic bout1;
    logic bout2;

  p3to3 test_p3to3(
    .fcontrol(fcontrol),
    .fin0(fin0),
    .fin1(fin1),
    .fin2(fin2),
    .bin0(bin0),
    .bin1(bin1),
    .bin2(bin2),
    .fout0(fout0),
    .fout1(fout1),
    .fout2(fout2),
    .bcontrol(bcontrol),
    .bout0(bout0),
    .bout1(bout1),
    .bout2(bout2)
  );

  initial begin
    $display("\n--------\nStarting Simulation!");

    #5
    {fcontrol, fin0, fin1, fin2} = 4'b1000;
    #5
    $display("%b", {fout0, fout1, fout2});

    #5
    {fcontrol, fin0, fin1, fin2} = 4'b0010;
    #5
    $display("%b", {fout0, fout1, fout2});

    #5
    {bin0, bin1, bin2} = 3'b110;
    #5
    $display("%b", {bout0, bout1, bout2, bcontrol});

    $finish;
  end
endmodule // p3to3_tb