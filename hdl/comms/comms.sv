module comms #(
  parameter DATA_DEPTH = 16384,
  parameter DATA_BRAM_WIDTH = 64,
  parameter DATA_SETS = 16,
  parameter WEIGHT_DEPTH = 49152,
  parameter WEIGHT_BRAM_WIDTH = 64,
  parameter WEIGHT_SETS = 16,
  parameter OP_DEPTH = 1024,
  parameter OP_BRAM_WIDTH = 8,
  parameter OP_SETS = 1
) (
  input wire clk_in,
  input wire rst_in,

  // UART receiver
  input wire rx_in,

  // Inputs from BRAM:
  input logic [DATA_BRAM_WIDTH-1:0] data_register_in,
  input logic [WEIGHT_BRAM_WIDTH-1:0] weight_register_in,
  input logic [OP_BRAM_WIDTH-1:0] op_register_in,

  // UART transmitter
  output logic tx_out,

  // Busy signal
  output logic busy_out,

  // Outputs to BRAM:
  // DATA
  output logic [$clog2(DATA_DEPTH)-1:0] data_addr_out,
  output logic [DATA_BRAM_WIDTH-1:0] data_register_out,
  output logic data_write_enable_out,
  output logic data_read_enable_out,

  // WEIGHT
  output logic [$clog2(WEIGHT_DEPTH)-1:0] weight_addr_out,
  output logic [WEIGHT_BRAM_WIDTH-1:0] weight_register_out,
  output logic weight_write_enable_out,
  output logic weight_read_enable_out,

  // OP
  output logic [$clog2(OP_DEPTH)-1:0] op_addr_out,
  output logic [OP_BRAM_WIDTH-1:0] op_register_out,
  output logic op_write_enable_out,
  output logic op_read_enable_out
 );

  localparam FRAME_SIZE = 8;
  
  // GET OP CODE
  localparam CLK_BAUD_RATIO = 25;
  localparam TYPE_SIZE = 3;
  localparam ADDR_SIZE = 16;
  localparam OP_SIZE = (TYPE_SIZE + ADDR_SIZE + FRAME_SIZE - 1) / FRAME_SIZE * FRAME_SIZE;

  logic [OP_SIZE-1:0] op_code;
  logic new_op;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(OP_SIZE / FRAME_SIZE)
  ) read_op (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(!busy_out && !new_op),
    .rx_in(rx_in),
    .data_out(op_code),
    .new_data_out(new_op)
  );

  // RECEIVING (LAPTOP -> FPGA)
  logic receive;

  logic set_data;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(DATA_BRAM_WIDTH / FRAME_SIZE)
  ) recv_data (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(receive && op_code[1:0]==2'b00),
    .rx_in(rx_in),
    .data_out(data_register_out),
    .new_data_out(set_data)
  );

    
  logic set_weight;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(WEIGHT_BRAM_WIDTH / FRAME_SIZE)
  ) recv_weight (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(receive && op_code[1:0]==2'b01),
    .rx_in(rx_in),
    .data_out(weight_register_out),
    .new_data_out(set_weight)
  );

  logic set_op;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(OP_BRAM_WIDTH / FRAME_SIZE)
  ) recv_op (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(receive && op_code[1:0]==2'b10),
    .rx_in(rx_in),
    .data_out(op_register_out),
    .new_data_out(set_op)
  );

  // TRANSMITTING (FPGA -> LAPTOP)
  logic transmit;
  assign tx_out = tx_data & tx_weight & tx_op;

  logic busy_transmitting_data;
  logic tx_data;
  trans #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(DATA_BRAM_WIDTH / FRAME_SIZE)
  ) trans_data (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_data_in(transmit && op_code[1:0]==2'b00),
    .data_in(data_register_in),
    .tx_out(tx_data),
    .busy_out(busy_transmitting_data)
  );

  logic busy_transmitting_weight;
  logic tx_weight;
  trans #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(WEIGHT_BRAM_WIDTH / FRAME_SIZE)
  ) trans_weight (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_data_in(transmit && op_code[1:0]==2'b01),
    .data_in(weight_register_in),
    .tx_out(tx_weight),
    .busy_out(busy_transmitting_weight)
  );

  logic busy_transmitting_op;
  logic tx_op;
  trans #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(OP_BRAM_WIDTH / FRAME_SIZE)
  ) trans_op (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_data_in(transmit && op_code[1:0]==2'b10),
    .data_in(op_register_in),
    .tx_out(tx_op),
    .busy_out(busy_transmitting_op)
  );


  logic [$clog2(WEIGHT_SETS+1)-1:0] set_counter; // Note: WEIGHT is widest type
  logic grabbed_register;
  always_ff @(posedge clk_in)begin
    receive <= 0;
    transmit <= 0;

    if (rst_in)begin
      busy_out <= 0;
    end else if (new_op)begin
      busy_out <= 1;
      receive <= !(op_code[2]);
      case (op_code[1:0])
        2'b00: data_addr_out <= DATA_SETS * op_code[OP_SIZE-1:OP_SIZE-ADDR_SIZE];
        2'b01: weight_addr_out <= WEIGHT_SETS * op_code[OP_SIZE-1:OP_SIZE-ADDR_SIZE];
        2'b10: op_addr_out <= OP_SETS * op_code[OP_SIZE-1:OP_SIZE-ADDR_SIZE];
        default: ;
      endcase
      set_counter <= 0;
    end else if (busy_out)begin
      case (op_code[2:0])
        3'b000: begin // Write to DATA
          if (data_write_enable_out)begin
            data_write_enable_out <= 0;
            data_addr_out <= data_addr_out + 1;
            if (set_counter == DATA_SETS)begin
              busy_out <= 0;
            end else begin
              receive <= 1;
            end
          end
          if (set_data)begin
            data_write_enable_out <= 1;
            set_counter <= set_counter + 1;
          end
        end
        3'b001: begin // Write to WEIGHT
          if (weight_write_enable_out)begin
            weight_write_enable_out <= 0;
            weight_addr_out <= weight_addr_out + 1;
            if (set_counter == WEIGHT_SETS)begin
              busy_out <= 0;
            end else begin
              receive <= 1;
            end
          end
          if (set_weight)begin
            weight_write_enable_out <= 1;
            set_counter <= set_counter + 1;
          end
        end
        3'b010: begin // Write to OP
          if (op_write_enable_out)begin
            op_write_enable_out <= 0;
            op_addr_out <= op_addr_out + 1;
            if (set_counter == OP_SETS)begin
              busy_out <= 0;
            end else begin
              receive <= 1;
            end
          end
          if (set_op)begin
            op_write_enable_out <= 1;
            set_counter <= set_counter + 1;
          end
        end
        3'b100: begin // Read from DATA
          if (!busy_transmitting_data && !transmit)begin
            if (grabbed_register)begin
              data_read_enable_out <= 0;
              transmit <= 1;
              grabbed_register <= 0;
              data_addr_out <= data_addr_out + 1;
            end else if(set_counter == DATA_SETS) begin
              busy_out <= 0;
              transmit <= 0;
            end else begin
              data_read_enable_out <= 1;
              grabbed_register <= 1;
              set_counter <= set_counter + 1;
            end
          end
        end
        3'b101: begin // Read from WEIGHT
          if (!busy_transmitting_weight && !transmit)begin
            if (grabbed_register)begin
              weight_read_enable_out <= 0;
              transmit <= 1;
              grabbed_register <= 0;
              weight_addr_out <= weight_addr_out + 1;
            end else if(set_counter == WEIGHT_SETS) begin
              busy_out <= 0;
              transmit <= 0;
            end else begin
              weight_read_enable_out <= 1;
              grabbed_register <= 1;
              set_counter <= set_counter + 1;
            end
          end
        end
        3'b110: begin // Read from OP
          if (!busy_transmitting_op && !transmit)begin
            if (grabbed_register)begin
              op_read_enable_out <= 0;
              transmit <= 1;
              grabbed_register <= 0;
              op_addr_out <= op_addr_out + 1;
            end else if(set_counter == OP_SETS) begin
              busy_out <= 0;
              transmit <= 0;
            end else begin
              op_read_enable_out <= 1;
              grabbed_register <= 1;
              set_counter <= set_counter + 1;
            end
          end
        end
        default:;
      endcase
    end
  end
endmodule // comms