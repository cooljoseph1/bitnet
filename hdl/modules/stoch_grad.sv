module stoch_grad #(
  parameter W_SIZE = 3072,
  parameter RANDOM_SEED = 1212,
  parameter NEG_LOG_LEARNING_RATE = 8
  ) (
    input wire clk_in,
    input wire rst_in,
    
    input wire [W_SIZE-1:0] flip_weight_in,
    output logic [W_SIZE-1:0] flip_weight_out
  );

  // This module takes in whether or not weights should be flipped and zeros out almost all of them
  integer i;
  integer j;
  logic [12:0] k;

  logic [15:0] random;
  lfsr_16 #(.SEED(RANDOM_SEED)) rng(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .q_out(random)
  );

  logic [12:0] middle_random; // gets all possible values unlike lfsr
  assign middle_random = random[14:2];

  always_comb begin
    for (i=0; i<W_SIZE; i = i+1)begin 
      k = 13'b1_1111_1111_1111;
      for(j=0; j < NEG_LOG_LEARNING_RATE; j = j+1)begin
        k ^= 13'b1 << ((3 * i * i * 17 + i * j * 19) % 13);
      end
      flip_weight_out[i] = flip_weight_in[i] & (&(middle_random | k));
    end
  end
endmodule // stoch_grad
