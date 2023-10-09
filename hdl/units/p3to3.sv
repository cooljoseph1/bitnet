`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module p3to3 (
    input wire fcontrol,
    input wire [2:0] fin,
    input wire [2:0] bin,
    output logic [2:0] fout,
    output logic bcontrol,
    output logic [2:0] bout
  );

  // forward pass
  logic fout_single;
  maj3_gate forward(.control(fcontrol), .in(fin), .out(fout_single));
  assign fout = {fout_single, fout_single, fout_single};
  
  // backward pass
  logic bout_single;
  maj3_gate backward(.control(1'b0), .in(bin), .out(bout_single));
  assign bout = {bout_single, bout_single, bout_single};
  assign bcontrol = bout_single;

endmodule // p3to3
`default_nettype wire