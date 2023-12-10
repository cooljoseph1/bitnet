// Receive multiple frames (usually one frame = one byte)

module recv #(
  parameter CLK_BAUD_RATIO = 25,
  parameter FRAME_SIZE = 8,
  parameter FRAMES = 2
) (
  input wire clk_in,
  input wire rst_in,
  input wire receive_in,
  input wire rx_in,
  output logic [DATA_SIZE-1:0] data_out,
  output logic new_data_out,
  output logic busy_out
 );

 localparam DATA_SIZE = FRAME_SIZE * FRAMES;

 logic [$clog2(DATA_SIZE+1)-1:0] counter = 0;
 logic [FRAME_SIZE-1:0] frame;
 logic new_frame;

 rx #(
  .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
  .DATA_SIZE(FRAME_SIZE)
 ) read_frame (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .rx_in(rx_in),
  .data_out(frame),
  .new_data_out(new_frame)
 );

 logic [DATA_SIZE-1:0] data;
 integer i;

 always_ff @(posedge clk_in)begin
  new_data_out <= 0;
  if (rst_in)begin
   counter <= 0;
   busy_out <= 0;
   new_data_out <= 0;
  end else if (!busy_out && receive_in)begin
    busy_out <= 1;
    counter <= 0;
  end else if (busy_out)begin
    if (counter == DATA_SIZE)begin
        busy_out <= 0;
        new_data_out <= 1;
        counter <= 0;
        data_out <= data;
    end else if (new_frame)begin
      for (i=0; i<FRAME_SIZE; i = i+1)begin
        data[counter+i] <= frame[i];
      end
      counter <= counter + FRAME_SIZE;
    end
  end
 end

endmodule