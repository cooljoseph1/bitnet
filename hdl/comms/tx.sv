module tx #(
  parameter CLK_BAUD_RATIO = 25,
  parameter DATA_SIZE = 8
) (
  input wire clk_in,
  input wire rst_in,
  input wire new_data_in,
  input wire [DATA_SIZE-1:0] data_in,
  output logic tx_out,
  output logic busy_out
 );
  
  logic [$clog2(CLK_BAUD_RATIO)-1:0] baud_checker;
  logic [$clog2(DATA_SIZE+2)-1:0] counter;
  logic [DATA_SIZE-1:0] data;
  always_ff @(posedge clk_in)begin
    baud_checker <= baud_checker == CLK_BAUD_RATIO-1? 0 : baud_checker + 1;
    if (rst_in)begin
      baud_checker <= 0;
      counter <= 0;
      busy_out <= 0;
      tx_out <= 1;
    end else if (new_data_in && !busy_out)begin
      data <= data_in;
      busy_out <= 1;
      counter <= DATA_SIZE+1;
    end else if (busy_out && baud_checker == 0)begin
      counter <= counter + 1;
      if (counter == DATA_SIZE+1)begin
        counter <= 0;
        tx_out <= 0;
      end else if (counter == DATA_SIZE)begin
        tx_out <= 1;
        busy_out <= 0;
      end else begin
        tx_out <= data[counter];
      end
    end
  end
endmodule