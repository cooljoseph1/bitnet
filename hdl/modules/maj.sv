module majority (
  input wire [2:0] in,
  output logic out
  );

  assign out = (in[0] & in[1]) ^ (in[1] & in[2]) ^ (in[2] & in[0]);

endmodule // majority

module weighted_majority (
  input wire [2:0] x_in,
  input wire [2:0] w_in,
  output logic out
  );

  majority maj (
    .in(x_in ^ w_in),
    .out(out)
  );

endmodule // weighted_majority