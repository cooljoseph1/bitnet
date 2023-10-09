`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module p3to2 (
    input wire oscillator, // ring oscillator for random third input in backwards pass
    input wire fcontrol,
    input wire [2:0] fin,
    input wire [1:0] bin,
    output logic [1:0] fout,
    output logic bcontrol,
    output logic [2:0] bout
  );

  // forward pass
  logic fout_single;
  maj3_gate forward(.control(fcontrol), .in(fin), .out(fout_single));
  assign fout = {fout_single, fout_single};
  
  // backward pass
  logic bout_single;

  // Split up the bin to make iverilog happy
  logic bin0;
  logic bin1;
  assign bin0 = bin[0];
  assign bin1 = bin[1];
  
  always_comb begin
    bout_single = oscillator? bin0 : bin1;
  end
  assign bout = {bout_single, bout_single, bout_single};
  assign bcontrol = bout_single;

endmodule // p3to2
`default_nettype wire