/*
We would like to store data and values that are larger than the maximum width allowed by the BRAM.
To do this, we split it up into a bunch of smaller pieces. The pieces are stored so that the
least significant N bits are saved in the first address in RAM, the next N bits are saved in the
next address, and so on.
*/

module bram_wrapper #(
    parameter ADDRS = 1024,
    parameter BRAM_WIDTH = 64,
    parameter PIECES = 32
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with the module that wants the wrapper */
    input wire [ADDR_SIZE-1:0] addr_in, // tell the data medium what data to extract
    output logic [WIDTH-1:0] data_out, // x value of data at the above pointer address
    input wire [WIDTH-1:0] data_in, // x value of data at the above pointer address
    input wire read_enable,  // should we read?
    input wire write_enable,  // we should write the input to the bram at the current addr_in
    output logic finished_out,


    /* communication with the BRAM */
    input wire [BRAM_WIDTH-1:0] bram_dout, // the dout from the BRAM
    output logic [BRAM_ADDR_SIZE-1:0] bram_addr, // the addr from the BRAM
    output logic bram_we, // the we from the BRAM
    output logic bram_regce, // the regce from the BRAM
    output logic [BRAM_WIDTH-1:0] bram_din // the din from the BRAM
  );

  localparam ADDR_SIZE = $clog2(ADDRS);
  localparam BRAM_DEPTH = ADDRS * PIECES;
  localparam BRAM_ADDR_SIZE = $clog2(BRAM_DEPTH);
  localparam WIDTH = PIECES * BRAM_WIDTH;
  localparam PIECE_ADDR_SIZE = $clog2(PIECES + 1);
  integer i;

  logic [ADDR_SIZE-1:0] current_addr = 0;
  logic writing = 0; // Are we currently writing? If so, we will not be able to change our addr until finished.
  assign bram_we = writing;
  assign bram_regce = ~writing;
  logic [WIDTH-1:0] x = 0;

  logic [PIECE_ADDR_SIZE-1:0] piece_addr = 0; // Offset address of piece of cpu_x or cpu_y that is being read out by the BRAM
                                                  // The true address is addr_in * PIECES + cpu_piece_addr.
  logic finished_all_pieces = 0; // Are we reading pieces or writing pices still? If not, we are finished
  logic busy_reading = 0; // Reading from the BRAM takes two clock cycles. This is high on the clock cycle in between.

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      current_addr <= -1;
      x <= 0;
      piece_addr <= 0;
      bram_addr <= 0;
      finished_all_pieces <= 1;
      busy_reading <= 0;
      finished_out <= 0;
    end else begin
      if (write_enable && finished_all_pieces) begin
        x <= data_in;
        writing <= 1;
        piece_addr <= 0;
        bram_addr <= PIECES * addr_in - 1;
        finished_all_pieces <= 0;
        current_addr <= addr_in;
        finished_out <= 0;
      end else if (read_enable && finished_all_pieces) begin // default to always reading from addr_in
        // We just got assigned a new place to read from!!
        finished_all_pieces <= 0;
        piece_addr <= 0;
        bram_addr <= PIECES * addr_in;
        busy_reading <= 1;
        current_addr <= addr_in;
        finished_out <= 0;
      end else if (!finished_all_pieces) begin
        if (writing) begin
          // we are writing
          if (piece_addr < PIECES) begin
            for (i=0; i<BRAM_WIDTH; i = i+1)begin
              bram_din[i] <= x[piece_addr * BRAM_WIDTH + i];
            end
            piece_addr <= piece_addr + 1;
            bram_addr <= bram_addr + 1;
          end else begin
            // We have finished writing!
            finished_all_pieces <= 1;
            writing <= 0;
            finished_out <= 1;
          end
        end else begin
          // we are reading, keep on reading
          if (busy_reading) begin
            busy_reading <= 0;
            // do nothing else--waste a clock cycle because the BRAM takes two clock cycles to read
          end else begin
            if (piece_addr < PIECES) begin // read into x:
              x <= {bram_dout, x[WIDTH-1:BRAM_WIDTH]};
              piece_addr <= piece_addr + 1;
              bram_addr <= bram_addr + 1;
              busy_reading <= 1;
            end else begin
              x <= {bram_dout, x[WIDTH-1:BRAM_WIDTH]};
              // We have finished reading!
              finished_all_pieces <= 1;
              finished_out <= 1;
              data_out <= {bram_dout, x[WIDTH-1:BRAM_WIDTH]};
            end
          end
        end
      end else begin
        // do nothing else--we are done writing and done reading and didn't receive a new pointer to read from
      end
    end
  end



endmodule // bram_wrapper