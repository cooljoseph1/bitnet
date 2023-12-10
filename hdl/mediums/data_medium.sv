module data_medium #(
    parameter ADDRS = 1024,
    parameter BRAM_WIDTH = 64,
    parameter PIECES = 16
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with cpu */
    input wire [ADDR_SIZE-1:0] addr_in, // tell the data medium what data to extract
    input wire read_enable,
    output logic [X_WIDTH-1:0] x_out, // value of data at the above addr address
    output logic [X_WIDTH-1:0] y_out, // value of data at the above addr address
    output logic finished_out,

    /* communication with the BRAM */
    input wire [BRAM_WIDTH-1:0] bram_dout, // the dout from the BRAM
    output logic [BRAM_ADDR_SIZE-1:0] bram_addr, // the addr from the BRAM
    output logic bram_we, // the we from the BRAM
    output logic bram_regce, // the regce from the BRAM
    output logic [BRAM_WIDTH-1:0] bram_din // the din from the BRAM
  );

  localparam ADDR_SIZE = $clog2(ADDRS);
  localparam BRAM_ADDR_SIZE = $clog2(ADDRS * PIECES * 2);
  localparam X_WIDTH = PIECES * BRAM_WIDTH;

  bram_wrapper #(
    .ADDRS(ADDRS),
    .BRAM_WIDTH(BRAM_WIDTH),
    .PIECES(2 * PIECES) // *2 because we have both x and y data
  ) internal_wrapper (
    .clk_in(clk_in),
    .rst_in(rst_in),

    .addr_in(addr_in),
    .data_out({x_out, y_out}),
    .data_in({X_WIDTH{2'b00}}),
    .read_enable(read_enable),
    .write_enable(1'b0),
    .finished_out(finished_out),

    .bram_dout(bram_dout),
    .bram_addr(bram_addr),
    .bram_we(bram_we),
    .bram_regce(bram_regce),
    .bram_din(bram_din)
  );

endmodule // data_medium
