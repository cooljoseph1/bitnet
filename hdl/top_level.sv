`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level #(
  parameter DATA_ADDRS = 512,
	parameter DATA_SIZE = 2048,
	parameter DATA_BRAM_WIDTH = 64,
	parameter WEIGHT_ADDRS = 128,
	parameter WEIGHT_SIZE = 3072,
	parameter WEIGHT_BRAM_WIDTH = 64,
	parameter HEAP_ADDRS = 128,
	parameter HEAP_BRAM_WIDTH = 64,
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

  localparam X_SIZE = DATA_SIZE / 2;
	localparam DATA_PIECES = DATA_SIZE / DATA_BRAM_WIDTH;
  localparam X_PIECES = DATA_PIECES / 2;
	localparam DATA_DEPTH = DATA_ADDRS * DATA_PIECES;
	localparam WEIGHT_PIECES = WEIGHT_SIZE / WEIGHT_BRAM_WIDTH;
	localparam WEIGHT_DEPTH = WEIGHT_ADDRS * WEIGHT_PIECES;
	localparam HEAP_DEPTH = HEAP_ADDRS * X_PIECES;
  localparam OP_PIECES = OP_SIZE / OP_BRAM_WIDTH;
  localparam OP_DEPTH = OP_ADDRS * OP_PIECES;
  
  localparam DATA_ADDR_SIZE = $clog2(DATA_ADDRS);
  localparam DATA_BRAM_ADDR_SIZE = $clog2(DATA_DEPTH);
  localparam WEIGHT_ADDR_SIZE = $clog2(WEIGHT_ADDRS);
  localparam WEIGHT_BRAM_ADDR_SIZE = $clog2(WEIGHT_DEPTH);
  localparam HEAP_ADDR_SIZE = $clog2(HEAP_ADDRS);
  localparam HEAP_BRAM_ADDR_SIZE = $clog2(HEAP_DEPTH);
  localparam OP_ADDR_SIZE = $clog2(OP_ADDRS);

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
    .DATA_PIECES(DATA_PIECES),
    .WEIGHT_DEPTH(WEIGHT_DEPTH),
    .WEIGHT_BRAM_WIDTH(WEIGHT_BRAM_WIDTH),
    .WEIGHT_PIECES(WEIGHT_PIECES),
    .OP_DEPTH(OP_DEPTH),
    .OP_BRAM_WIDTH(OP_BRAM_WIDTH),
    .OP_PIECES(OP_PIECES)
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


  /* ALL THE THINGS TO DO WITH THE CPU */
  logic [X_SIZE-1:0] cpu_inference_out;
  logic cpu_inference_valid_out;

  /* First, pair the instruction with BRAM via a medium */
  logic [OP_ADDR_SIZE-1:0] instruction_cpu_addr;
  logic [OP_SIZE-1:0] instruction;
  logic instruction_valid;

  logic [OP_BRAM_WIDTH-1:0] instruction_dout;
  logic [OP_ADDR_SIZE-1:0] instruction_bram_addr;
  logic instruction_we;
  logic instruction_regce;
  logic [OP_BRAM_WIDTH-1:0] instruction_din;
  instruction_medium #(
    .ADDRS(OP_ADDRS),
    .OP_SIZE(OP_SIZE)
  ) instruction_medium_module (
    /* clock and reset */
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),

    /* communication with cpu */
    .addr_in(instruction_cpu_addr),
    .instruction_out(instruction),
    .valid_out(instruction_valid),

    /* communication with the BRAM */
    .bram_dout(instruction_dout), // the dout from the BRAM
    .bram_addr(instruction_bram_addr), // the addr from the BRAM
    .bram_we(instruction_we), // the we from the BRAM
    .bram_regce(instruction_regce), // the regce from the BRAM
    .bram_din(instruction_din) // the din from the BRAM
  );
  /* Done with the instruction medium */

  /* Second, pair the data with BRAM via a medium */
  logic [DATA_ADDR_SIZE-1:0] data_cpu_addr;
  logic [X_SIZE-1:0] data_x;
  logic [X_SIZE-1:0] data_y;
  logic data_finished;

  logic [DATA_BRAM_WIDTH-1:0] data_dout;
  logic [DATA_BRAM_ADDR_SIZE-1:0] data_bram_addr;
  logic data_we;
  logic data_regce;
  logic [DATA_BRAM_WIDTH-1:0] data_din;
  data_medium #(
    .ADDRS(DATA_ADDRS),
    .BRAM_WIDTH(DATA_BRAM_WIDTH),
    .PIECES(X_PIECES)
  ) data_medium_module (
    /* clock and reset */
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),

    /* communication with cpu */
    .addr_in(data_cpu_addr),
    .x_out(data_x),
    .y_out(data_y),
    .finished_out(data_finished),

    /* communication with the BRAM */
    .bram_dout(data_dout), // the dout from the BRAM
    .bram_addr(data_bram_addr), // the addr from the BRAM
    .bram_we(data_we), // the we from the BRAM
    .bram_regce(data_regce), // the regce from the BRAM
    .bram_din(data_din) // the din from the BRAM
  );
  /* Done with the data medium */

  /* Third, pair the weights with BRAM via a medium */
  logic [WEIGHT_ADDR_SIZE-1:0] weight_cpu_addr;
  logic [WEIGHT_SIZE-1:0] weight_write;
  logic [WEIGHT_SIZE-1:0] weight_read;
  logic weight_cpu_we;
  logic weight_cpu_re;
  logic weight_finished;

  logic [WEIGHT_BRAM_WIDTH-1:0] weight_dout;
  logic [WEIGHT_BRAM_ADDR_SIZE-1:0] weight_bram_addr;
  logic weight_bram_we;
  logic weight_bram_regce;
  logic [WEIGHT_BRAM_WIDTH-1:0] weight_din;
  weight_medium #(
    .ADDRS(WEIGHT_ADDRS),
    .BRAM_WIDTH(WEIGHT_BRAM_WIDTH),
    .PIECES(WEIGHT_PIECES)
  ) weight_medium_module (
    /* clock and reset */
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),

    /* communication with cpu */
    .addr_in(weight_cpu_addr),
    .weight_in(weight_write),
    .weight_out(weight_read),
    .read_enable(weight_cpu_re),
    .write_enable(weight_cpu_we),
    .finished_out(weight_finished),

    /* communication with the BRAM */
    .bram_dout(weight_dout), // the dout from the BRAM
    .bram_addr(weight_bram_addr), // the addr from the BRAM
    .bram_we(weight_bram_we), // the we from the BRAM
    .bram_regce(weight_bram_regce), // the regce from the BRAM
    .bram_din(weight_din) // the din from the BRAM
  );
  /* Done with the weight medium */

  /* Fourth (and finally), pair the heap with BRAM via a medium */
  logic [HEAP_ADDR_SIZE-1:0] heap_cpu_addr;
  logic [X_SIZE-1:0] heap_write;
  logic [X_SIZE-1:0] heap_read;
  logic heap_cpu_we;
  logic heap_cpu_re;
  logic heap_finished;

  logic [HEAP_BRAM_WIDTH-1:0] heap_dout;
  logic [HEAP_BRAM_ADDR_SIZE-1:0] heap_bram_addr;
  logic heap_bram_we;
  logic heap_bram_regce;
  logic [HEAP_BRAM_WIDTH-1:0] heap_din;
  heap_medium #(
    .ADDRS(HEAP_ADDRS),
    .BRAM_WIDTH(HEAP_BRAM_WIDTH),
    .PIECES(X_PIECES)
  ) heap_medium_module (
    /* clock and reset */
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),

    /* communication with cpu */
    .addr_in(heap_cpu_addr),
    .data_in(heap_write),
    .data_out(heap_read),
    .read_enable(heap_cpu_re),
    .write_enable(heap_cpu_we),
    .finished_out(heap_finished),

    /* communication with the BRAM */
    .bram_dout(heap_dout), // the dout from the BRAM
    .bram_addr(heap_bram_addr), // the addr from the BRAM
    .bram_we(heap_bram_we), // the we from the BRAM
    .bram_regce(heap_bram_regce), // the regce from the BRAM
    .bram_din(heap_din) // the din from the BRAM
  );
  /* Done with the weight medium */

  
  cpu #(
    .PROGRAM_LENGTH(OP_ADDRS),
    .DATA_LENGTH(DATA_ADDRS),
    .WEIGHT_LENGTH(WEIGHT_ADDRS),
    .HEAP_LENGTH(HEAP_ADDRS),
    .INSTRUCTION_SIZE(OP_SIZE),
    .X_SIZE(X_SIZE),
    .W_SIZE(WEIGHT_SIZE),
    .TRIT_SIZE(4)
  ) cpu_module (
    /* clock  and reset */
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),

    .inference_out(cpu_inference_out),
    .inference_valid_out(cpu_inference_valid_out),

    /* communication with instruction medium. */
    .instruction_addr_out(instruction_cpu_addr), // pointer to the instruction we want in memory
    .instruction_in(instruction), // the instruction from the instruction medium
    .instruction_valid_in(instruction_valid),
    
    /* communication with data medium. */
    .data_addr_out(data_cpu_addr), // tell the data medium where to read
    .data_x_in(data_x), // x value of data at the above pointer address
    .data_y_in(data_y), // y value of data at the above pointer address
    .data_medium_finished_in(data_finished),

    /* communication with weight medium. */
    .weight_addr_out(weight_cpu_addr), // tell the weight medium where to read/write
    .weight_in(weight_read), // input from the weight medium
    .weight_out(weight_write), // output to the weight medium
    .weight_read_enable_out(weight_cpu_re),
    .weight_write_enable_out(weight_cpu_we),
    .weight_medium_finished_in(weight_finished),

    /* communication with heap medium. */
    .heap_addr_out(heap_cpu_addr), // tell the heap medium where to read/write
    .heap_in(heap_read), // input from the heap medium
    .heap_out(heap_write), // output to the heap medium
    .heap_read_enable_out(heap_cpu_re),
    .heap_write_enable_out(heap_cpu_we),
    .heap_medium_finished_in(heap_finished)
  );

  /* END OF ALL THE THINGS TO DO WITH THE CPU */


  
	xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(DATA_BRAM_WIDTH),					   // Specify RAM data width
    .RAM_DEPTH(DATA_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_bram (
    .addra(comm_data_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(data_bram_addr),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_data_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(data_din),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(clk_100mhz),	 // Port B clock
    .wea(comm_data_we),	   // Port A write enable
    .web(data_we),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_data_re), // Port A output register enable
    .regceb(data_regce), // Port B output register enable
    .douta(comm_data_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(data_dout)	// Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(WEIGHT_BRAM_WIDTH),					   // Specify RAM weight width
    .RAM_DEPTH(WEIGHT_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) weight_bram (
    .addra(comm_weight_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(weight_bram_addr),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_weight_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(weight_din),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(clk_100mhz),	 // Port B clock
    .wea(comm_weight_we),	   // Port A write enable
    .web(weight_bram_we),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_weight_re), // Port A output register enable
    .regceb(weight_bram_regce), // Port B output register enable
    .douta(comm_weight_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(weight_dout)	// Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(HEAP_BRAM_WIDTH),					   // Specify RAM weight width
    .RAM_DEPTH(HEAP_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) heap_bram (
    .addra(),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(heap_bram_addr),   // Port B address bus, width determined from RAM_DEPTH
    .dina(),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(heap_din),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(),	 // Port A clock
    .clkb(clk_100mhz),	 // Port B clock
    .wea(),	   // Port A write enable
    .web(heap_bram_we),	   // Port B write enable
    .ena(1'b0),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(), // Port A output register enable
    .regceb(heap_bram_regce), // Port B output register enable
    .douta(),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(heap_dout)	// Port B RAM output data, width determined from RAM_WIDTH
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(OP_BRAM_WIDTH),					   // Specify RAM data width
    .RAM_DEPTH(OP_DEPTH),					 // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")						// Specify name/location of RAM initialization file if using one (leave blank if not)
  ) op_bram (
    .addra(comm_op_addr),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(instruction_bram_addr),   // Port B address bus, width determined from RAM_DEPTH
    .dina(comm_op_register_in),	 // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(instruction_din),	 // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk_100mhz),	 // Port A clock
    .clkb(clk_100mhz),	 // Port B clock
    .wea(comm_op_we),	   // Port A write enable
    .web(instruction_we),	   // Port B write enable
    .ena(1'b1),	   // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b1),	   // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(1'b0),	 // Port A output reset (does not affect memory contents)
    .rstb(1'b0),	 // Port B output reset (does not affect memory contents)
    .regcea(comm_op_re), // Port A output register enable
    .regceb(instruction_regce), // Port B output register enable
    .douta(comm_op_register_out),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(instruction_dout)	// Port B RAM output data, width determined from RAM_WIDTH
  );
	
 
endmodule // top_level
 
// reset the default net type to wire, sometimes other code expects this.
`default_nettype wire