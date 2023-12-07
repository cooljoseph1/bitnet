// Transmit multiple frames (usually one frame = one byte)

module trans #(
  parameter CLK_BAUD_RATIO = 25,
  parameter FRAME_SIZE = 8,
  parameter FRAMES = 2
) (
  input wire clk_in,
  input wire rst_in,
  input wire new_data_in,
  input wire [DATA_SIZE-1:0] data_in,
  output logic tx_out,
  output logic busy_out
 );

 localparam DATA_SIZE = FRAME_SIZE * FRAMES;

 logic [$clog2(CLK_BAUD_RATIO)-1:0] baud_checker;
 logic [$clog2(DATA_SIZE+1)-1:0] counter;
 logic [FRAME_SIZE-1:0] frame;
 logic new_frame;
 logic tx_busy;

 tx #(
  .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
  .DATA_SIZE(FRAME_SIZE)
 ) send_frame (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .new_data_in(new_frame),
  .data_in(frame),
  .tx_out(tx_out),
  .busy_out(tx_busy)
 );
 logic [DATA_SIZE-1:0] data;
 integer i;

 always_ff @(posedge clk_in)begin
  baud_checker <= baud_checker == CLK_BAUD_RATIO-1? 0 : baud_checker + 1;
  new_frame <= 0;
  if (rst_in)begin
   baud_checker <= 0;
   counter <= 0;
   busy_out <= 0;
  end else if (new_data_in && !busy_out)begin
      data <= data_in;
      busy_out <= 1;
      counter <= 0;
  end else if (busy_out)begin
    if (!tx_busy && !new_frame)begin
      for (i=0; i<FRAME_SIZE; i = i+1)begin
        frame[i] <= data[counter+i];
      end
      counter <= counter + FRAME_SIZE;
      if (counter == DATA_SIZE)begin
        busy_out <= 0;
      end else begin
        new_frame <= 1;
      end
    end
  end
 end

endmodule