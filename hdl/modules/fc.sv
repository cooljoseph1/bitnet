`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module fc #(
    parameter N = 27
 )
 
 (
    input wire clk_in,
    input wire rst_in,
    input wire oscillator,
    input wire fd_prop, // signal to start forward propagation
    input wire bk_prop, // signal to start backward propagation
    
    input wire [N-1:0] fin,
    input wire [N-1:0] bin,

    output logic fd_prop_done, // signal that the forward propagation is done
    output logic bk_prop_done, // signal that the backward propagation is done
    output logic [N-1:0] control_out [0:NUM_LAYERS-1], // to get the saved weights

    output logic [N-1:0] fout,
    output logic [N-1:0] bout
  );

  localparam NUM_LAYERS = clog3(N);
  logic [N-1:0] fh [0:NUM_LAYERS]; // not NUM_LAYERS-1. Makes indexing easier.
  logic [N-1:0] bh [0:NUM_LAYERS];
  assign fh[0] = fin;
  assign bh[NUM_LAYERS] = bin;
  
  logic [NUM_LAYERS:0] fd_prop_dones;
  assign fd_prop_dones[0] = fd_prop;
  assign fd_prop_done = fd_prop_dones[NUM_LAYERS];
  logic [NUM_LAYERS:0] bk_prop_dones;
  assign bk_prop_done = bk_prop_dones[0];
  assign bk_prop_dones[NUM_LAYERS] = bk_prop;

  genvar l, i;
  generate
    for(l=0; l < NUM_LAYERS; l=l+1) begin
        for(i=0; i<N; i=i+1)begin
          if (z3(i,l))begin
            unit3to3 unit(
              .rst_in(rst_in),
              .clk_in(clk_in),
              .oscillator(oscillator),
              .fd_prop(fd_prop),
              .bk_prop(bk_prop),
              .fin({
                fh[l][i],
                fh[l][p3(i,l)%N],
                fh[l][n3(i,l)%N]
              }),
              .bin({
                bh[l+1][i],
                bh[l+1][p3(i,l)%N],
                bh[l+1][n3(i,l)%N]
              }),
              .fout({
                fh[l+1][i],
                fh[l+1][p3(i,l)%N],
                fh[l+1][n3(i,l)%N]
              }),
              .bout({
                bh[l][i],
                bh[l][p3(i,l)%N],
                bh[l][n3(i,l)%N]
              }),
              .control_out(control_out[l][i])
            );
          end
        end

        signal_delay fd_layer_done(
          .clk_in(clk_in),
          .rst_in(rst_in),
          .in_signal(fd_prop_dones[l]),
          .out_signal(fd_prop_dones[l + 1])
        );
        
        signal_delay bk_layer_done(
          .clk_in(clk_in),
          .rst_in(rst_in),
          .in_signal(bk_prop_dones[l + 1]),
          .out_signal(bk_prop_dones[l])
        );
    end
  endgenerate
  


endmodule // fc
`default_nettype wire