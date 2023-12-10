`timescale 1ns / 1ps
`default_nettype none

module rx_tb();
  logic clk_in;
  logic rst_in;
  logic rx_in;
  logic [3:0] data;
  logic new_data;
  logic busy;

  rx #(
    .CLK_BAUD_RATIO(5),
    .DATA_SIZE(4)
  ) test_rx (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rx_in(rx_in),
    .data_out(data),
    .new_data_out(new_data),
    .busy_out(busy)
 );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("vcd/comms/rx.vcd");
    $dumpvars(1,test_rx);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    rx_in = 0;
    
    // Send 4'b0110
    #50
    rx_in = 0;
    #50
    rx_in = 1;
    #50
    rx_in = 1;
    #50
    rx_in = 0;

    #50
    rx_in = 1;
    #50

    $finish;
  end
endmodule // rx_tb