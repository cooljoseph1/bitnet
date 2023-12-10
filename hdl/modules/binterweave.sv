module binterweave #(
  parameter X_SIZE = 1024,
  parameter W_SIZE = 1024,
  parameter TRIT_SIZE = 4
  ) (
    input wire [X_SIZE-1:0] y,
    input wire [W_SIZE-1:0] w,
    input wire [TRIT_SIZE-1:0] trit,
    output logic [X_SIZE-1:0] x,
    output logic [W_SIZE-1:0] grad
  );

  // TODO: MAKE THIS MODULE
  assign x = y;
  assign grad = w;

endmodule // binterweave