`timescale 1ns / 1ps
`default_nettype none

module top_level_tb_for_cpu();
  logic clk_in;
  logic rst_in;
  logic rx_in;
  logic tx_out;

  logic [7:0] word = 8'h00;

  /* The instruction set in more readable terms */
  localparam SET_I_TO_0 = 0; // "I = 0"
  localparam SET_TRIT_TO_NEXT_VALUE = 1; // "TRIT = NEXT"
  localparam SET_H_TO_NEXT_VALUE = 2; // "H = NEXT"
  localparam D_INCREMENT = 3; // "D++"
  localparam D_DECREMENT = 4; // "D--"
  localparam A_INCREMENT = 5; // "A++"
  localparam A_DECREMENT = 6; // "A--"
  localparam SET_X_TO_VALUE_AT_D0 = 7; // "X = *D[0]"
  localparam SET_Y_TO_VALUE_AT_D1 = 8; // "Y = *D[1]"
  localparam SET_XY_TO_VALUE_AT_D = 9; // "X, Y = *D"
  localparam SET_INFERENCE_TO_Y = 10; // "INFERENCE = Y"
  localparam SET_W_TO_VALUE_AT_A = 11; // "W = *A"
  localparam SET_VALUE_AT_A_TO_W = 12; // "*A = W"
  localparam SET_X_TO_VALUE_AT_H = 13; // "X = *H"
  localparam SET_VALUE_AT_H_TO_X = 14; // "*H = X"
  localparam SWAP_XY = 15; // "X, Y = Y, X"
  localparam SET_X_TO_Y = 16; // "X = Y"
  localparam SET_Y_TO_X = 17; // "Y = X"
  localparam SET_X_TO_X_XOR_Y = 18; // "X = X ^ Y"
  localparam SET_Y_TO_X_XOR_Y = 19; // "Y = X ^ Y"
  localparam SET_X_TO_X_AND_Y = 20; // "X = X & Y"
  localparam SET_Y_TO_X_AND_Y = 21; // "Y = X & Y"
  localparam SET_X_TO_X_OR_Y = 22; // "X = X | Y"
  localparam SET_Y_TO_X_OR_Y = 23; // "Y = X | Y"
  localparam INTERWEAVE = 24; // "INTERWEAVE"
  localparam BACKPROP = 25; // "BACKPROP"
  localparam STOCH_GRAD = 26; // "STOCH GRAD"

  localparam DATA_SIZE=2048;
  localparam DATA_BRAM_WIDTH=64;

  top_level #(
    .DATA_ADDRS(2),
	  .DATA_SIZE(DATA_SIZE),
	  .DATA_BRAM_WIDTH(DATA_BRAM_WIDTH),
	  .WEIGHT_ADDRS(2),
	  .WEIGHT_SIZE(96),
    .WEIGHT_BRAM_WIDTH(8),
	  .HEAP_ADDRS(2),
    .OP_ADDRS(1024),
    .OP_SIZE(8),
    .OP_BRAM_WIDTH(8)
  ) test_top_level (
	.clk_100mhz(clk_in),
    .sys_rst(rst_in),
    .uart_rxd(rx_in),
    .uart_txd(tx_out)
  );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("vcd/cpu/top_level.vcd");
    $dumpvars(1,test_top_level);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    rx_in = 1;

    // Send test data
    for (int i=0; i < 3; i=i+1)begin
      #250
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = 0;
      end
      #250
      rx_in = 1;
    end
    
    for (int i=0; i<DATA_SIZE/DATA_BRAM_WIDTH; i=i+1)begin
      for (int j=0; j<DATA_BRAM_WIDTH/8; j=j+1)begin
        #250
        rx_in = 0;
        for (int k=0; k<8; k=k+1)begin
          #250
          rx_in = word[k] + i;
        end
        #250
        rx_in = 1;
      end
    end

    #40000

    
    // Send ops
    for (int i=0; i < 3; i=i+1)begin
      #250
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = (i==0 && j == 1);
      end
      #250
      rx_in = 1;
    end

    for (int i=0; i<1; i=i+1)begin
      for (int j=0; j<1; j=j+1)begin
        #250
        rx_in = 0;
        for (int k=0; k<8; k=k+1)begin
          #250
          rx_in = SET_X_TO_VALUE_AT_D0[k];
        end
        #250
        rx_in = 1;
      end
    end

    #1000

    for (int i=0; i < 3; i=i+1)begin
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = (i==0 && j == 1) || (i == 1 && j == 0);
      end
      #250
      rx_in = 1;
    end

    for (int i=0; i<1; i=i+1)begin
      for (int j=0; j<1; j=j+1)begin
        #250
        rx_in = 0;
        for (int k=0; k<8; k=k+1)begin
          #250
          rx_in = SET_Y_TO_X_OR_Y[k];
        end
        #250
        rx_in = 1;
      end
    end

    #1000

    for (int i=0; i < 3; i=i+1)begin
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = (i==0 && j == 1) || (i == 1 && j == 1);
      end
      #250
      rx_in = 1;
    end

    for (int i=0; i<1; i=i+1)begin
      for (int j=0; j<1; j=j+1)begin
        #250
        rx_in = 0;
        for (int k=0; k<8; k=k+1)begin
          #250
          rx_in = SET_INFERENCE_TO_Y[k];
        end
        #250
        rx_in = 1;
      end
    end

    #10000

    // Read from INFERENCE
    for (int i=0; i < 3; i=i+1)begin
      #250
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = (i==0 && j<=2);
      end
      #250
      rx_in = 1;
    end

    #400000
    // rst_in = 0;
    // end

    $finish;
  end
endmodule // top_level_tb_for_cpu