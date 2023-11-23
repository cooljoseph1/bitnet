module recv #(
    parameter REGISTER_SIZE = 1024;
    parameter CLK_BAUD_RATIO = 8;
) (
    input wire clk_in,
    input wire rst_in,
    input wire receiving_in,
    input wire tx_in,
    output logic busy_out,
    output logic [REGISTER_SIZE-1] register_out
  );

  logic [$clog2(CLK_BAUD_RATIO)-1:0] baud_checker;
  logic [$clog2(REGISTER_SIZE)-1:0] counter;
  always_ff @(posedge clk_in)begin
    baud_checker <= baud_checker == CLK_BAUD_RATIO-1? 0 : baud_checker + 1;
    if (rst_in)begin
      baud_checker <= 0;
      counter <= 0;
    end else if (receiving_in && baud_checker == 0) begin
      counter <= counter + 1;
      busy_out <= 1;
      if (counter == REGISTER_SIZE - 1) begin
        counter <= 0;
        busy_out <= 0;
      end else begin
        register_out[counter] <= tx_in;
      end
    end
  end

endmodule