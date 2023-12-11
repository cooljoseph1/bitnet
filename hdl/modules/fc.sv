`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module fc #(
    parameter N = 27
 )
 
 (
    input wire clk_in,
    input wire rst_in,
    input wire [7:0] rnd_in,
    input wire oscillator,
    input wire fd_prop, // signal to start forward propagation
    input wire bk_prop, // signal to start backward propagation
    
    input wire [N-1:0] fin,
    input wire [N-1:0] bin,

    output logic fd_prop_done, // signal that the forward propagation is done
    output logic bk_prop_done, // signal that the backward propagation is done
    output logic [NUM_LAYERS-1:0][(N/3)-1:0] control_out, // to get the saved weights

    output logic [N-1:0] fout,
    output logic [N-1:0] bout
  );

  localparam NUM_LAYERS = 2;//$clog3(N);
  logic [NUM_LAYERS:0][N-1:0] fh ; // not NUM_LAYERS-1. Makes indexing easier.
  logic [NUM_LAYERS:0][N-1:0] bh;
  assign fh[0] = fin;
  assign bh[NUM_LAYERS] = bin;
  assign fout = fh[NUM_LAYERS];
  assign bout = bh[0];
  
  logic [NUM_LAYERS:0] fd_prop_dones;
  assign fd_prop_dones[0] = fd_prop;
  assign fd_prop_done = fd_prop_dones[NUM_LAYERS];
  logic [NUM_LAYERS:0] bk_prop_dones;
  assign bk_prop_done = bk_prop_dones[0];
  assign bk_prop_dones[NUM_LAYERS] = bk_prop;

  genvar l, i, j;
  generate
    for(l = 0; l < NUM_LAYERS; l = l + 1) begin
      for(i = 0; i < N; i = i + 3**(l + 1)) begin
        for(j = i; j < (i + 3**l); j = j + 1) begin
          unit3to3 #(.THRESHOLD((213 * (l + i * i + j * j * j + 2)) % 150 + 101)) unit(
            .rst_in(rst_in),
            .clk_in(clk_in),
            .rnd_in(rnd_in),
            .oscillator(oscillator),
            .fd_prop(fd_prop_dones[l]),
            .bk_prop(bk_prop_dones[l+1]),
            .fin({
              fh[l][j%N],
              fh[l][(j+(3**l))%N],
              fh[l][(j+(2*3**l))%N]
            }),
            .bin({
              bh[l+1][j%N],
              bh[l+1][(j+(3**l))%N],
              bh[l+1][(j+(2*3**l))%N]
            }),
            .fout({
              fh[l+1][j%N],
              fh[l+1][(j+(3**l))%N],
              fh[l+1][(j+(2*3**l))%N]
            }),
            .bout({
              bh[l][j%N],
              bh[l][(j+(3**l))%N],
              bh[l][(j+(2*3**l))%N]
            }),
            .control_out(control_out[l][j-i+(i / 3)])
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