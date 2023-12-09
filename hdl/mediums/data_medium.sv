`timescale 1ns / 1ps
`default_nettype none; // prevents system from inferring an undeclared logic (good practice)


/* DATA IS STORED IN MANY PIECES IN THE BRAMS. THE PIECES ARE ORDERED MSB, i.e., the most significant bit is the first bit of the first piece */
module data_medium #(
    parameter DATA_ADDRS = 1024,
    parameter X_SIZE = 1024,
    parameter BRAM_WIDTH = 64,
  ) (
    /* clock and reset */
    input wire clk_in,
    input wire rst_in,

    /* communication with cpu */
    input logic [$clog2(DATA_ADDRS)-1:0] cpu_pointer_in; // tell the data medium what data to extract
    output wire [X_SIZE-1:0] cpu_x_out; // x value of data at the above pointer address
    output wire [X_SIZE-1:0] cpu_y_out; // y value of data at the above pointer address
    // There are no other ready/valid signals because everything else is always valid and ready
    output wire cpu_out_valid;
  );

  localparam D_SIZE = $clog2(DATA_ADDRS);
  localparam PIECES = 2 * X_SIZE / BRAM_WIDTH; // number of pieces each data is broken into to be saved in RAM.
                                               // The x2 is because there is both an x and a y part to the data
  localparam PIECE_ADDR_SIZE = $clog2(X_PIECES);

  localparam BRAM_DEPTH = DATA_ADDRS * PIECES;
  localparam LOG_BRAM_DEPTH = $clog2(BRAM_DEPTH);

  logic [D_SIZE-1:0] cpu_previous_pointer = 0;
  logic [X_SIZE-1:0] cpu_x = 0;
  assign cpu_x_out = cpu_x;
  logic [X_SIZE-1:0] cpu_y = 0;
  assign cpu_y_out = cpu_y;

  logic [PIECE_ADDR_SIZE-1:0] cpu_piece_addr = 0; // Offset address of piece of cpu_x or cpu_y that is being read out by the BRAM
                                                  // The true address is cpu_pointer_in * PIECES + cpu_piece_addr.
  logic [LOG_BRAM_DEPTH-1:0] cpu_true_addr;
  assign cpu_true_addr = cpu_pointer_in * PIECES + cpu_piece_addr;
  logic cpu_finished_all_pieces = 0; // Are we reading x pieces or y pieces? Or are we done? working = 0, done = 1
  assign cpu_out_valid = cpu_finished_all_pieces;

  logic cpu_busy_reading = 0; // Reading from the BRAM takes two clock cycles. This is high on the clock cycle in between.
  logic [BRAM_WIDTH-1:0] cpu_read_out;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      cpu_previous_pointer <= -1;
      cpu_x <= 0;
      cpu_y <= 0;
      cpu_piece_addr <= 0;
      cpu_finished_all_pieces <= 0;
      cpu_busy_reading <= 0;
    end else begin
      if (cpu_previous_pointer != cpu_pointer_in) begin
        // We just got assigned a new place to read from!! Start reading from it
        cpu_finished_all_pieces <= 0;
        cpu_piece_addr <= 0;
        cpu_busy_reading <= 1;
      end else if (!cpu_finished_all_pieces) begin
        // keep on reading
        if (cpu_busy_reading) begin
          // do nothing--waste a clock cycle because the BRAM takes two clock cycles to read
        end else begin
          if (cpu_piece_addr < (PIECES / 2)) begin // read into cpu_x:
            cpu_x <= {cpu_x[X_SIZE-BRAM_WIDTH-1:0], cpu_read_out};
            cpu_piece_addr <= cpu_piece_addr + 1;
          end else if (cpu_piece_addr < PIECES) begin // read into cpu_y:
            cpu_y <= {cpu_y[X_SIZE-BRAM_WIDTH-1:0], cpu_read_out};
            cpu_piece_addr <= cpu_piece_addr + 1;
          end else begin
            // We have finished reading!
            cpu_finished_all_pieces <= 1;
          end
        end
      end else begin
        // do nothing--we are done reading and didn't receive a new pointer
      end
    end
  end


/* TODO: James, put in the communications part here */
  

/* The actual bram */
xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(DATA_BRAM_WIDTH),					   // Specify RAM data width
    .RAM_DEPTH(DATA_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_bram (
    .addra(comm_data_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(cpu_true_addr),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_data_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(clk_in),	 // Port B clock
    .wea(comm_data_we),	   // Port A write enable
    .web(1'b0),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_data_re), // Port A output register enable
    .regceb(!cpu_finished_all_pieces), // Port B output register enable
    .douta(comm_data_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(cpu_read_out)	// Port B RAM output data, width determined from RAM_WIDTH
  );


endmodule; // cpu
`default_nettype wire