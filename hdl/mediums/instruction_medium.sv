module instruction_medium #(
    parameter ADDRS = 256,
    parameter OP_SIZE = 8
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with cpu */
    input wire [ADDR_SIZE-1:0] addr_in,
    input wire ready_in,
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
  assign bram_regce = 1'b1;
  assign bram_din = {OP_SIZE{1'b0}};

  logic finished = 1'b0;
  assign valid_out = finished;

  logic [ADDR_SIZE-1:0] read_addr = 0;
  assign bram_addr = read_addr;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      read_addr <= 0;
      finished <= 1'b0;
    end else if (ready_in) begin
      read_addr <= addr_in;
      finished <= 1'b0;
    end else begin
      finished <= 1'b1;
      instruction_out <= bram_dout;
    end
  end

endmodule // instruction_medium
