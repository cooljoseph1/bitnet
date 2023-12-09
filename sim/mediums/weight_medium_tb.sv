`timescale 1ns / 1ps
`default_nettype none

module weight_medium_tb();
  logic clk_in;
  logic rst_in;


  localparam ADDRS = 24;
  localparam ADDR_SIZE = $clog2(ADDRS);
  localparam BRAM_WIDTH = 64;
  localparam PIECES = 4;
  localparam BRAM_DEPTH = ADDRS * PIECES;
  localparam BRAM_ADDR_SIZE = $clog2(BRAM_DEPTH);
  localparam WIDTH = BRAM_WIDTH * PIECES;


  logic [BRAM_WIDTH-1:0] bram_dout;
  logic [BRAM_ADDR_SIZE-1:0] bram_addr;
  logic bram_we;
  logic bram_regce;
  logic [BRAM_WIDTH-1:0] bram_din;


  logic [ADDR_SIZE-1:0] addr_in;
  logic [WIDTH-1:0] weight_out;
  logic [WIDTH-1:0] weight_in;
  logic write_enable;
  logic finished_out;


	xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(BRAM_WIDTH),					   // Specify RAM data width
    .RAM_DEPTH(BRAM_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_bram (
    .addra(bram_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(),   // Port B address bus, width determined from RAM_DEPTH
    .dina(bram_din),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),	 // Port A clock
    .clkb(),	 // Port B clock
    .wea(bram_we),	   // Port A write enable
    .web(),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(bram_regce), // Port A output register enable
    .regceb(), // Port B output register enable
    .douta(bram_dout),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb()	// Port B RAM output data, width determined from RAM_WIDTH
  );


  weight_medium #(
    .ADDRS(ADDRS),
    .BRAM_WIDTH(BRAM_WIDTH),
    .PIECES(PIECES)
  ) test_weight_medium (
    .clk_in(clk_in),
    .rst_in(rst_in),
    
    .bram_dout(bram_dout),
    .bram_addr(bram_addr),
    .bram_we(bram_we),
    .bram_regce(bram_regce),
    .bram_din(bram_din),

    .addr_in(addr_in),
    .weight_out(weight_out),
    .weight_in(weight_in),
    .write_enable(write_enable),
    .finished_out(finished_out)
  );

  always begin
      #5;
      clk_in = !clk_in;
  end

  initial begin
    $dumpfile("vcd/mediums/weight_medium_tb.vcd");
    $dumpvars(1,test_weight_medium);
    $display("\n--------\nStarting Simulation!");
    clk_in = 0;
    rst_in = 1;

    #10
    rst_in = 0;

    // write some data
    addr_in = 0;
    weight_in = 256'hBEAD0000BE0011228888888888888888BEAD0000BE0011228888888888888888;
    write_enable = 1;

    #10
    write_enable = 0;

    #1000
    addr_in = 12;
    weight_in = 256'h1212121200001212777777777777777712121212000012127777777777777777;
    write_enable = 1;

    #10
    write_enable = 0;

    #1000
    addr_in = 0;

    #1000

    addr_in = 12;

    #1000


    $finish;
  end
endmodule // bram_wrapper_tb