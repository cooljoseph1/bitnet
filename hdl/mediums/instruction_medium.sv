module instruction_medium #(
    parameter ADDRS = 256,
    parameter BRAM_WIDTH = 8
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with cpu */
    input logic [ADDR_SIZE-1:0] addr_in,
    output wire [BRAM_WIDTH-1:0] instruction_out,
    output wire finished_out,

    /* communication with the BRAM */
    input wire [BRAM_WIDTH-1:0] bram_dout, // the dout from the BRAM
    output logic [ADDR_SIZE-1:0] bram_addr, // the addr from the BRAM
    output logic bram_we, // the we from the BRAM
    output logic bram_regce, // the regce from the BRAM
    output logic [BRAM_WIDTH-1:0] bram_din // the din from the BRAM
  );


  

  localparam ADDR_SIZE = $clog2(ADDRS);

  assign bram_we = 1'b0;
  assign bram_addr = addr_in;
  assign bram_regce = 1'b1;
  assign bram_din = {BRAM_WIDTH{1'b0}};

  logic [ADDR_SIZE-1:0] prev_addr = 0;

  logic finished;
  assign finished_out = finished;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      prev_addr <= -1;
      finished <= 1'b0;
    end else if (prev_addr != addr_in) begin
      prev_addr <= addr_in;
      finished <= 1'b0;
    end else begin
      finished <= 1'b1;
    end
  end

endmodule // instruction_medium
