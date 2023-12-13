module lfsr_16 #(
    parameter SEED = 1212
  ) ( input wire clk_in, input wire rst_in,
                    output logic [15:0] q_out);

  logic [15:0] q = SEED;
  assign q_out = q;
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        q <= SEED;
    end else begin
        q[0] <= q[15];
        q[1] <= q[0];
        q[2] <= q[15] ^ q[1];
        q[3] <= q[2];
        q[4] <= q[3];
        q[5] <= q[4];
        q[6] <= q[5];
        q[7] <= q[6];
        q[8] <= q[7];
        q[9] <= q[8];
        q[10] <= q[9];
        q[11] <= q[10];
        q[12] <= q[11];
        q[13] <= q[12];
        q[14] <= q[13];
        q[15] <= q[15] ^ q[14];
    end
  end

endmodule