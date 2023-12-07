`timescale 1ns / 1ps
`default_nettype none

module tx_tb();
  logic clk_in;
  logic rst_in;
  logic tx_out;
  logic [3:0] data;
  logic new_data;
  logic busy;

  tx #(
    .CLK_BAUD_RATIO(2),
    .DATA_SIZE(4)
  ) test_tx (
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
    $dumpfile("vcd/comms/tx.vcd");
    $dumpvars(1,test_tx);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    new_data = 1;
    data = 4'b0110;
    #200

    $finish;
  end
endmodule // tx_tb