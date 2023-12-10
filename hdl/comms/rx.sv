module rx #(
  parameter CLK_BAUD_RATIO = 25,
  parameter DATA_SIZE = 8
) (
  input wire clk_in,
  input wire rst_in,
  input wire rx_in,
  output logic [DATA_SIZE-1:0] data_out,
  output logic new_data_out,
  output logic busy_out
 );

  logic [$clog2(CLK_BAUD_RATIO)-1:0] baud_checker;
  logic [$clog2(DATA_SIZE+1)-1:0] counter;
  logic [DATA_SIZE-1:0] data;
  always_ff @(posedge clk_in)begin
    baud_checker <= baud_checker == CLK_BAUD_RATIO-1? 0 : baud_checker + 1;
    new_data_out <= 0;
    if (rst_in)begin
      busy_out <= 0;
      baud_checker <= 0;
      counter <= 0;
    end else if (!busy_out && !rx_in) begin // start busy_out
        busy_out <= 1;
        counter <= 0;
        baud_checker <= 1;
    end else if (baud_checker == 0) begin
      if (busy_out) begin
        counter <= counter + 1;
        if (counter == DATA_SIZE)begin
          busy_out <= 0;
          new_data_out <= 1;
          data_out <= data;
        end else begin
          data[counter] <= rx_in;
        end
      end
    end
  end
endmodule