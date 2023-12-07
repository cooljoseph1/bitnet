module rx_copy #(
  parameter CLK_BAUD_RATIO = 25,
  parameter OP_SIZE = 3 + 16 // 3 for read/write + BRAM, 16 for BRAM address.
) (
  input wire clk_in,
  input wire rst_in,
  input wire rx_in,
  output logic [OP_SIZE-1:0] op_code_out,
  output logic new_op_out
 );

  logic receiving;
  logic [$clog2(CLK_BAUD_RATIO)-1:0] baud_checker;
  logic [1:0] counter;
  always_ff @(posedge clk_in)begin
    baud_checker <= baud_checker == CLK_BAUD_RATIO-1? 0 : baud_checker + 1;
    if (rst_in)begin
      receiving <= 0;
      baud_checker <= 0;
      counter <= 0;
    end else if (baud_checker == 0) begin
      if (!receiving && rx_in) begin // start receiving
        receiving <= 0;
        counter <= 0;
      end else if (receiving) begin
        counter <= counter + 1;
        op_code_out[counter] <= rx_in;
        new_op_out <= 0;
        if (counter == OP_SIZE-1) begin
          receiving <= 0;
          new_op_out <= 1;
        end
      end
    end
  end
endmodule