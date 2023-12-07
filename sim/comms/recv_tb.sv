`timescale 1ns / 1ps
`default_nettype none

module recv_tb();
  logic clk_in;
  logic rst_in;
  logic rx_in;
  
  logic [23:0] data_out;
  logic new_data_out;
  logic busy_out;

  logic [23:0] word = {8'h4E, 8'h3B, 8'h2F};

  // 4E = 0100 1110
  // 9C = 1001 1101

  recv #(
    .CLK_BAUD_RATIO(2),
    .FRAME_SIZE(8),
    .FRAMES(3)
  ) test_recv (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(1'b1),
    .rx_in(rx_in),
    .data_out(data_out),
    .new_data_out(new_data_out),
    .busy_out(busy_out)
 );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("vcd/comms/recv.vcd");
    $dumpvars(1,test_recv);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    rx_in = 1;
    
    #100

    // Send word three times
    for (int i=0; i < 3; i=i+1)begin
      #20
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #20
        rx_in = word[i*8+j];
      end
      #20
      rx_in = 1;
    end

    #100

    $finish;
  end
endmodule // recv_tb