`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module program_counter #(parameter LENGTH=256)(
    input wire clk_in,
    input wire rst_in,
    input wire ready_in, // control unit is ready for a new instruction
    output wire valid_out, // new instruction is valid--probably always the case
    output wire [3:0] instruction_out // the instruction to send to the control unit. 4 bits encoded
  );

  localparam JUMP_INSTRUCTION = 4'b1111;

  logic [3:0] instruction;
  // The ROM that contains our instructions
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(4),                       // Specify RAM data width
    .RAM_DEPTH(LENGTH),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(program.mem))       // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) image_rom (
    .addra(instruction_addr),     // Address bus, width determined from RAM_DEPTH
    .dina({4{1'b0}}),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(instruction)      // RAM output data, width determined from RAM_WIDTH
  );

  localparam INSTRUCTION_WAIT = 0;
  localparam INSTRUCTION_READY = 1;
  localparam JUMP0_WAIT = 2;
  localparam JUMP0_READY = 3;
  localparam JUMP1_WAIT = 4;
  localparam JUMP1_READY = 5;
  logic [2:0] state;
  logic [3:0] jump0_saved;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      valid_out <= 1'b0;
      instruction_out <= 4'b0000;
      instruction_addr <= 1'b0;
      state <= INSTRUCTION_WAIT;
      jump0_saved <= 4'b0000;
    end else begin
      case(state) begin
        INSTRUCTION_WAIT: begin
          // do nothing. We're waiting for the data to get out of ram and into  `instruction`
          valid_out <= 0;
        end
        JUMP0_WAIT: begin
          // also do nothing
          valid_out <= 0;
        end
        JUMP1_WAIT: begin
          // also do nothing
          valid_out <= 0;
        end
        INSTRUCTION_READY: begin
          // The instruction has been read into `instruction` from RAM and we need to act on it
          if (instruction == JUMP_INSTRUCTION) begin
            instruction_addr <= instruction_addr + 1;
            state <= JUMP0_WAIT;
            valid_out <= 0;
          end else begin
            instruction_out <= instruction;
            valid_out <= 1;
          end
        end
        JUMP0_READY: begin
          jump0_saved <= instruction;
          state <= JUMP1_WAIT;
          valid_out <= 0;
        end
        JUMP1_READY: begin
          instruction_addr <= {jump0_saved, instruction};
          state <= INSTRUCTION_WAIT;
          valid_out <= 0;
        end
        default: begin
          // undefined behavior
          valid_out <= 0;
          state <= INSTRUCTION_WAIT;
        end
      endcase
    end
  end

endmodule // unit3to3
`default_nettype wire