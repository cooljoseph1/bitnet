`timescale 1ns / 1ps
`default_nettype none

module trans_tb();
  logic clk_in;
  logic rst_in;
  logic tx_out;
  logic [7:0] data;
  logic new_data;
  logic busy;

  trans #(
  .CLK_BAUD_RATIO(2),
  .FRAME_SIZE(4),
  .FRAMES(2)
  ) test_trans (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_data_in(new_data),
    .data_in(data),
    .tx_out(tx_out),
    .busy_out(busy)
 );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("vcd/comms/trans.vcd");
    $dumpvars(1,test_trans);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    new_data = 1;
    data = 8'b10101100;
    #500

    $finish;
  end
endmodule // trans_tb