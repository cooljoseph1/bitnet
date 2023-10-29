`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module accum #(
    parameter THRESHOLD=255
  )(
    input wire clk_in,
    input wire rst_in,
    input wire prop_in, // are we backwards propagating?
    input wire inc, // are we incrementing or decrementing?
    output logic trigger
  );
  
  localparam COUNT_SIZE = $clog2(THRESHOLD);
  logic [COUNT_SIZE-1:0] count;
  
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      count <= 0;
      trigger <= 0;
    end else if (prop_in) begin
      if (count == THRESHOLD && inc)begin
        count <= 0;
        trigger <= 1;
      end else begin
        count <= inc? count + 1 : (count == 0? 0 : count - 1);
        trigger <= 0;
      end
    end
  end
 
endmodule // accum
`default_nettype wire