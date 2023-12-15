module interweave #(
  parameter X_SIZE = 729,
  parameter W_SIZE = 729 * 3,
  parameter TRIT_SIZE = 4
  ) (
    input wire [X_SIZE-1:0] x,
    input wire [W_SIZE-1:0] w,
    input wire [TRIT_SIZE-1:0] trit,
    output logic [X_SIZE-1:0] y
  );

  genvar i;
  generate
    for (i = 0; i < X_SIZE; i = i + 1) begin
      logic [2:0] x_in;
      always_comb begin
        case(trit)
          0: x_in = {x[i>=3**0? i-3**0 : X_SIZE+i-3**0], x[(i + 3**0) % X_SIZE], x[i]};
          1: x_in = {x[i>=3**1? i-3**1 : X_SIZE+i-3**1], x[(i + 3**1) % X_SIZE], x[i]};
          2: x_in = {x[i>=3**2? i-3**2 : X_SIZE+i-3**2], x[(i + 3**2) % X_SIZE], x[i]};
          3: x_in = {x[i>=3**3? i-3**3 : X_SIZE+i-3**3], x[(i + 3**3) % X_SIZE], x[i]};
          4: x_in = {x[i>=3**4? i-3**4 : X_SIZE+i-3**4], x[(i + 3**4) % X_SIZE], x[i]};
          // 5: x_in = {x[i>=3**5? i-3**5 : X_SIZE+i-3**5], x[(i + 3**5) % X_SIZE], x[i]};
          // 6: x_in = {x[i>=3**6? i-3**6 : X_SIZE+i-3**6], x[(i + 3**6) % X_SIZE], x[i]};
          default: x_in = 0;
        endcase
      end

      weighted_majority maj (
        .x_in(x_in),
        .w_in(w[3*i+2:3*i]),
        .out(y[i])
      );
    end
  endgenerate

endmodule // interweave