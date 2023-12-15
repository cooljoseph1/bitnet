module binterweave #(
  parameter X_SIZE = 1024,
  parameter W_SIZE = 1024,
  parameter TRIT_SIZE = 4
  ) (
    input wire [X_SIZE-1:0] x,
    input wire [W_SIZE-1:0] w,
    input wire [X_SIZE-1:0] dy,
    input wire [TRIT_SIZE-1:0] trit,
    output logic [X_SIZE-1:0] dx,
    output logic [W_SIZE-1:0] dw
  );

  // NOTE: Need x to be pushed before the interweave.

  logic [X_SIZE-1:0] y;
  logic [X_SIZE-1:0] d;
  assign d = y ^ dy;
  interweave fwd (.x(x), .w(w), .trit(trit), .y(y));

  genvar i;
  generate
    for (i = 0; i < X_SIZE; i = i + 1) begin
      logic [2:0] dx_in;
      // dx values
      always_comb begin
        case(trit)
          0:
            dx_in = {
              x[i] ^ d[(i + 3**0)%X_SIZE] ^ w[3*((i+3**0)%X_SIZE)+2],
              x[i] ^ d[i>=3**0? i-3**0 : X_SIZE+i-3**0] ^ w[i>=3**0? 3*(i-3**0)+1 : 3*(X_SIZE+i-3**0)+1],
              x[i] ^ d[i] ^ w[3*i]
            };
          1:
            dx_in = {
              x[i] ^ d[(i + 3**1)%X_SIZE] ^ w[3*((i+3**1)%X_SIZE)+2],
              x[i] ^ d[i>=3**1? i-3**1 : X_SIZE+i-3**1] ^ w[i>=3**1? 3*(i-3**1)+1 : 3*(X_SIZE+i-3**1)+1],
              x[i] ^ d[i] ^ w[3*i]
            };
            
          2:
            dx_in = {
              x[i] ^ d[(i + 3**2)%X_SIZE] ^ w[3*((i+3**2)%X_SIZE)+2],
              x[i] ^ d[i>=3**2? i-3**2 : X_SIZE+i-3**2] ^ w[i>=3**2? 3*(i-3**2)+1 : 3*(X_SIZE+i-3**2)+1],
              x[i] ^ d[i] ^ w[3*i]
            };
            
          3:
            dx_in = {
              x[i] ^ d[(i + 3**3)%X_SIZE] ^ w[3*((i+3**3)%X_SIZE)+2],
              x[i] ^ d[i>=3**3? i-3**3 : X_SIZE+i-3**3] ^ w[i>=3**3? 3*(i-3**3)+1 : 3*(X_SIZE+i-3**3)+1],
              x[i] ^ d[i] ^ w[3*i]
            };
            
          4:
            dx_in = {
              x[i] ^ d[(i + 3**4)%X_SIZE] ^ w[3*((i+3**4)%X_SIZE)+2],
              x[i] ^ d[i>=3**4? i-3**4 : X_SIZE+i-3**4] ^ w[i>=3**4? 3*(i-3**4)+1 : 3*(X_SIZE+i-3**4)+1],
              x[i] ^ d[i] ^ w[3*i]
            };
            
          // 5:
          //   dx_in = {
          //     x[i] ^ d[(i + 3**5)%X_SIZE] ^ w[3*((i+3**5)%X_SIZE)+2],
          //     x[i] ^ d[i>=3**5? i-3**5 : X_SIZE+i-3**5] ^ w[i>=3**5? 3*(i-3**5)+1 : 3*(X_SIZE+i-3**5)+1],
          //     x[i] ^ d[i] ^ w[3*i]
          //   };
            
          // 6:
          //   dx_in = {
          //     x[i] ^ d[(i + 3**6)%X_SIZE] ^ w[3*((i+3**6)%X_SIZE)+2],
          //     x[i] ^ d[i>=3**6? i-3**0 : X_SIZE+i-3**6] ^ w[i>=3**6? 3*(i-3**6)+1 : 3*(X_SIZE+i-3**6)+1],
          //     x[i] ^ d[i] ^ w[3*i]
          //   };
          default: dx_in = 0;
        endcase
      end

      majority dx_out (
        .in(dx_in),
        .out(dx[i])
      );

      // dw values
      always_comb begin
        case (trit)
          0: dw[3*i+2:3*i] = {
                x[i>=3**0? i-3**0 : X_SIZE+i-3**0] ^ d[i] ^ w[3*i+2],
                x[(i+3**0)%X_SIZE] ^ d[i] ^ w[3*i+1],
                x[i] ^ d[i] ^ w[3*i]
              };
          1: dw[3*i+2:3*i] = {
                x[i>=3**1? i-3**1 : X_SIZE+i-3**1] ^ d[i] ^ w[3*i+2],
                x[(i+3**1)%X_SIZE] ^ d[i] ^ w[3*i+1],
                x[i] ^ d[i] ^ w[3*i]
              };
          2: dw[3*i+2:3*i] = {
                x[i>=3**2? i-3**2 : X_SIZE+i-3**2] ^ d[i] ^ w[3*i+2],
                x[(i+3**2)%X_SIZE] ^ d[i] ^ w[3*i+1],
                x[i] ^ d[i] ^ w[3*i]
              };
          3: dw[3*i+2:3*i] = {
                x[i>=3**3? i-3**3 : X_SIZE+i-3**3] ^ d[i] ^ w[3*i+2],
                x[(i+3**3)%X_SIZE] ^ d[i] ^ w[3*i+1],
                x[i] ^ d[i] ^ w[3*i]
              };
          4: dw[3*i+2:3*i] = {
                x[i>=3**4? i-3**4 : X_SIZE+i-3**4] ^ d[i] ^ w[3*i+2],
                x[(i+3**4)%X_SIZE] ^ d[i] ^ w[3*i+1],
                x[i] ^ d[i] ^ w[3*i]
              };
          // 5: dw[3*i+2:3*i] = {
          //       x[i>=3**5? i-3**5 : X_SIZE+i-3**5] ^ d[i] ^ w[3*i+2],
          //       x[(i+3**5)%X_SIZE] ^ d[i] ^ w[3*i+1],
          //       x[i] ^ d[i] ^ w[3*i]
          //     };
          // 6: dw[3*i+2:3*i] = {
          //       x[i>=3**6? i-3**6 : X_SIZE+i-3**6] ^ d[i] ^ w[3*i+2],
          //       x[(i+3**6)%X_SIZE] ^ d[i] ^ w[3*i+1],
          //       x[i] ^ d[i] ^ w[3*i]
          //     };
          default: dw[3*i+2:3*i] = 0;
        endcase
      end
    end
  endgenerate

endmodule // binterweave