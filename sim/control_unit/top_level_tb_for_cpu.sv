`timescale 1ns / 1ps
`default_nettype none

module top_level_tb_for_cpu();
  logic clk_in;
  logic rst_in;
  logic rx_in;
  logic tx_out;

  logic [7:0] word = 8'h36;

  top_level #(
    .DATA_ADDRS(2)
	  .DATA_SIZE(64),
	  .DATA_BRAM_WIDTH(8),
	  .WEIGHT_ADDRS(2),
	  .WEIGHT_SIZE(96),
    .WEIGHT_BRAM_WIDTH(8),
	  .HEAP_ADDRS(2),
	  .HEAP_BRAM_WIDTH(64),
    .OP_ADDRS(12),
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

    // Send three messages

    for(int m=0; m<3; m=m+1)begin
    
    // Send header
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

    // Send test data
    for (int i=0; i<16; i=i+1)begin
      #250
      for (int j=0; j<8; j=j+1)begin
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

    #1000

    // Read back what we just sent
    // Send 8'b0 three times
    for (int i=0; i < 3; i=i+1)begin
      #250
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = (i==0 && j==2) || (i==1 && j==0 && m==1);
      end
      #250
      rx_in = 1;
    end
    #400000
    rst_in = 0;
    end

    $finish;
  end
endmodule // top_level_tb_for_cpu