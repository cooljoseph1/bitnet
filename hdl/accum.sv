`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module accum #(
    parameter THRESHOLD=192,
    parameter PUSH_DOWN=10 // every 10 turns subtract one from the count. This is to avoid random walks making it trigger
  )(
    input wire rst_in,
    input wire clk_in,
    input wire prop_in,
    input wire inc,
    output logic trigger
  );
  
  localparam COUNT_SIZE = $clog2(THRESHOLD);
  localparam TIME_SIZE = $clog2(PUSH_DOWN);

  logic [TIME_SIZE-1:0] timer;
  logic [TIME_SIZE-1:0] new_timer;

  logic [COUNT_SIZE-1:0] count;
  logic [COUNT_SIZE-1:0] new_count;

  logic new_trigger;

  always_comb begin
    new_timer = (timer == (PUSH_DOWN - 1))? 0 : (timer + 1);
    new_trigger = inc? (count == (THRESHOLD - 1)) : 0;
    new_count = new_trigger? 0 : (inc?
      count + 1 : (count == 0? 0 : count - 1)
    );
    new_count = new_timer? new_count : (new_count == 0? 0 : new_count - 1);

  end
  
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      count <= 0;
      trigger <= 0;
      timer <= 0;
    end else if (prop_in) begin
      count <= new_count;
      trigger <= new_trigger;
      timer <= new_timer;
    end
  end
 
endmodule // accum
`default_nettype wire