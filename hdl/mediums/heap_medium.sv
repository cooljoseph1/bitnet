module heap_medium #(
    parameter ADDRS = 256,
    parameter BRAM_WIDTH = 64,
    parameter PIECES = 16
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with cpu */
    input wire [ADDR_SIZE-1:0] addr_in,
    output logic [WIDTH-1:0] data_out,
    input wire [WIDTH-1:0] data_in,
    input wire read_enable,
    input wire write_enable,
    output logic finished_out,

    /* communication with the BRAM */
    input wire [BRAM_WIDTH-1:0] bram_dout, // the dout from the BRAM
    output logic [BRAM_ADDR_SIZE-1:0] bram_addr, // the addr from the BRAM
    output logic bram_we, // the we from the BRAM
    output logic bram_regce, // the regce from the BRAM
    output logic [BRAM_WIDTH-1:0] bram_din // the din from the BRAM
  );

  localparam ADDR_SIZE = $clog2(ADDRS);
  localparam BRAM_ADDR_SIZE = $clog2(ADDRS * PIECES);
  localparam WIDTH = PIECES * BRAM_WIDTH;

  bram_wrapper #(
    .ADDRS(ADDRS),
    .BRAM_WIDTH(BRAM_WIDTH),
    .PIECES(PIECES)
  ) internal_wrapper (
    .clk_in(clk_in),
    .rst_in(rst_in),

    .addr_in(addr_in),
    .data_out(data_out),
    .data_in(data_in),
    .read_enable(read_enable),
    .write_enable(write_enable),
    .finished_out(finished_out),

    .bram_dout(bram_dout),
    .bram_addr(bram_addr),
    .bram_we(bram_we),
    .bram_regce(bram_regce),
    .bram_din(bram_din)
  );

endmodule // weight_medium
