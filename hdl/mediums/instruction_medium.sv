module instruction_medium #(
    parameter ADDRS = 256,
    parameter OP_SIZE = 8
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with cpu */
    input wire [ADDR_SIZE-1:0] addr_in,
    output logic [OP_SIZE-1:0] instruction_out,
    output logic valid_out,

    /* communication with the BRAM */
    input wire [OP_SIZE-1:0] bram_dout, // the dout from the BRAM
    output logic [ADDR_SIZE-1:0] bram_addr, // the addr from the BRAM
    output logic bram_we, // the we from the BRAM
    output logic bram_regce, // the regce from the BRAM
    output logic [OP_SIZE-1:0] bram_din // the din from the BRAM
  );


  

  localparam ADDR_SIZE = $clog2(ADDRS);

  assign bram_we = 1'b0;
  assign bram_addr = addr_in;
  assign bram_regce = 1'b1;
  assign bram_din = {OP_SIZE{1'b0}};

  logic [ADDR_SIZE-1:0] prev_addr = 0;

  logic finished;
  assign valid_out = finished;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      prev_addr <= -1;
      finished <= 1'b0;
    end else if (prev_addr != addr_in) begin
      prev_addr <= addr_in;
      finished <= 1'b0;
    end else begin
      finished <= 1'b1;
      instruction_out <= bram_dout;
    end
  end

endmodule // instruction_medium
