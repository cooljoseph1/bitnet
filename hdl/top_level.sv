`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level #(
  parameter DATA_ADDRS = 1024,
	parameter DATA_SIZE = 1024,
	parameter DATA_BRAM_WIDTH = 64,
	parameter WEIGHT_ADDRS = 128,
	parameter WEIGHT_SIZE = 3072,
	parameter WEIGHT_BRAM_WIDTH = 64,
  parameter OP_ADDRS = 1024,
  parameter OP_SIZE = 8,
  parameter OP_BRAM_WIDTH = 8
  ) (
	input wire clk_100mhz,
	input wire sys_rst,
	input wire uart_rxd,

  output logic [15:0] led,
	output logic [2:0] rgb0, //rgb led
	output logic [2:0] rgb1, //rgb led
	output logic uart_txd
	);

  assign led = comm_data_addr;

  assign rgb0 = 0;
  assign rgb1 = 0;

	localparam DATA_SETS = DATA_SIZE / DATA_BRAM_WIDTH;
	localparam DATA_DEPTH = DATA_ADDRS * DATA_SETS;
	localparam WEIGHT_SETS = WEIGHT_SIZE / WEIGHT_BRAM_WIDTH;
	localparam WEIGHT_DEPTH = WEIGHT_ADDRS * WEIGHT_SETS;
  localparam OP_SETS = OP_SIZE / OP_BRAM_WIDTH;
  localparam OP_DEPTH = OP_ADDRS * OP_SETS;

  logic [$clog2(DATA_DEPTH)-1:0] comm_data_addr;
  logic [DATA_BRAM_WIDTH-1:0] comm_data_register_in;
  logic [DATA_BRAM_WIDTH-1:0] comm_data_register_out;
  logic comm_data_we;
  logic comm_data_re;

  logic [$clog2(WEIGHT_DEPTH)-1:0] comm_weight_addr;
  logic [WEIGHT_BRAM_WIDTH-1:0] comm_weight_register_in;
  logic [WEIGHT_BRAM_WIDTH-1:0] comm_weight_register_out;
  logic comm_weight_we;
  logic comm_weight_re;

  logic [$clog2(OP_DEPTH)-1:0] comm_op_addr;
  logic [OP_BRAM_WIDTH-1:0] comm_op_register_in;
  logic [OP_BRAM_WIDTH-1:0] comm_op_register_out;
  logic comm_op_we;
  logic comm_op_re;

  comms #(
    .DATA_DEPTH(DATA_DEPTH),
    .DATA_BRAM_WIDTH(DATA_BRAM_WIDTH),
    .DATA_SETS(DATA_SETS),
    .WEIGHT_DEPTH(WEIGHT_DEPTH),
    .WEIGHT_BRAM_WIDTH(WEIGHT_BRAM_WIDTH),
    .WEIGHT_SETS(WEIGHT_SETS),
    .OP_DEPTH(OP_DEPTH),
    .OP_BRAM_WIDTH(OP_BRAM_WIDTH),
    .OP_SETS(OP_SETS)
  ) comm_module (
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),
    
    .rx_in(uart_rxd),

    .data_register_in(comm_data_register_out),
    .weight_register_in(comm_weight_register_out),
    .op_register_in(comm_op_register_out),

    .data_addr_out(comm_data_addr),
    .data_register_out(comm_data_register_in),
    .data_write_enable_out(comm_data_we),
    .data_read_enable_out(comm_data_re),

    .weight_addr_out(comm_weight_addr),
    .weight_register_out(comm_weight_register_in),
    .weight_write_enable_out(comm_weight_we),
    .weight_read_enable_out(comm_weight_re),

    .op_addr_out(comm_op_addr),
    .op_register_out(comm_op_register_in),
    .op_write_enable_out(comm_op_we),
    .op_read_enable_out(comm_op_re),

    .tx_out(uart_txd)
  );
  
	xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(DATA_BRAM_WIDTH),					   // Specify RAM data width
    .RAM_DEPTH(DATA_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_bram (
    .addra(comm_data_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_data_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(),	 // Port B clock
    .wea(comm_data_we),	   // Port A write enable
    .web(),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_data_re), // Port A output register enable
    .regceb(), // Port B output register enable
    .douta(comm_data_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb()	// Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(WEIGHT_BRAM_WIDTH),					   // Specify RAM weight width
    .RAM_DEPTH(WEIGHT_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) weight_bram (
    .addra(comm_weight_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_weight_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(),	 // Port B clock
    .wea(comm_weight_we),	   // Port A write enable
    .web(),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_weight_re), // Port A output register enable
    .regceb(), // Port B output register enable
    .douta(comm_weight_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb()	// Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(OP_BRAM_WIDTH),					   // Specify RAM data width
    .RAM_DEPTH(OP_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) op_bram (
    .addra(comm_op_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_op_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(),	 // Port B clock
    .wea(comm_op_we),	   // Port A write enable
    .web(),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_op_re), // Port A output register enable
    .regceb(), // Port B output register enable
    .douta(comm_op_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb()	// Port B RAM output data, width determined from RAM_WIDTH
  );
	
 
endmodule // top_level
 
// reset the default net type to wire, sometimes other code expects this.
`default_nettype wire