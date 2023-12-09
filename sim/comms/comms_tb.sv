`timescale 1ns / 1ps
`default_nettype none

module comms_tb();
  logic clk_in;
  logic rst_in;
  logic rx_in;
  logic [63:0] data_register_in = 64'b0110011001100110011001100110011001100110011001100110011001100110;

  logic [7:0] word = 8'h36;
  logic tx_out;
  logic busy_out;

  logic [15:0] data_addr_out;
  logic [63:0] data_register_out;
  logic data_we_out;
  logic data_re_out;

  comms #(
    .DATA_DEPTH(1<<16),
    .DATA_BRAM_WIDTH(64),
    .DATA_PIECES(2)
  ) test_comms (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rx_in(rx_in),

    .data_register_in(data_register_in),

    .tx_out(tx_out),
    .busy_out(busy_out),
    .data_addr_out(data_addr_out),
    .data_register_out(data_register_out),
    .data_write_enable_out(data_we_out),
    .data_read_enable_out(data_re_out)
  );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("vcd/comms/comms.vcd");
    $dumpvars(1,test_comms);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;
    rx_in = 1;

    // Send three messages

    for(int m=0; m<3; m=m+1)begin
    #500
    
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
    for (int i=0; i<2; i=i+1)begin
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
    end

    #1000

    // Read back what we just sent
    // Send 8'b0 three times
    for (int i=0; i < 3; i=i+1)begin
      #250
      rx_in = 0;
      for (int j=0; j<8; j=j+1)begin
        #250
        rx_in = i==0 && j==2;
      end
      #250
      rx_in = 1;
    end

    #50000

    $finish;
  end
endmodule // comms_tb