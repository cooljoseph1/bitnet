module comms #(
  parameter DATA_DEPTH = 16384,
  parameter DATA_BRAM_WIDTH = 64,
  parameter DATA_PIECES = 16,
  parameter WEIGHT_DEPTH = 49152,
  parameter WEIGHT_BRAM_WIDTH = 64,
  parameter WEIGHT_PIECES = 16,
  parameter OP_DEPTH = 1024,
  parameter OP_BRAM_WIDTH = 8,
  parameter OP_PIECES = 1
) (
  input wire clk_in,
  input wire rst_in,

  // UART receiver
  input wire rx_in,

  // Inputs from BRAM:
  input wire [DATA_BRAM_WIDTH-1:0] data_register_in,
  input wire [WEIGHT_BRAM_WIDTH-1:0] weight_register_in,
  input wire [OP_BRAM_WIDTH-1:0] op_register_in,

  // Input from inference register:
  input wire [INF_WIDTH-1:0] inf_register_in,

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

  localparam FRAME_SIZE = 8; // UART sends one byte in each frame
  localparam CLK_BAUD_RATIO = 25; // Clock cycles per bit

  localparam WRITE = 1'b0;
  localparam READ = 1'b1;

  localparam DATA = 2'b00;
  localparam WEIGHT = 2'b01;
  localparam OP = 2'b10;
  localparam INF = 2'b11;
  
  // GET HEADER
  localparam TYPE_SIZE = 3;
  localparam ADDR_SIZE = 16;
  localparam HEADER_SIZE = (TYPE_SIZE + ADDR_SIZE + FRAME_SIZE - 1) / FRAME_SIZE * FRAME_SIZE; // round to multiple of frame_size

  logic [HEADER_SIZE-1:0] header;
  logic new_header;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(HEADER_SIZE / FRAME_SIZE)
  ) read_header (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(!busy_out && !new_header),
    .rx_in(rx_in),
    .data_out(header),
    .new_data_out(new_header)
  );

  // RECEIVING (LAPTOP -> FPGA)
  logic receive;

  logic piece_data;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(DATA_BRAM_WIDTH / FRAME_SIZE)
  ) recv_data (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(receive && header[1:0]==DATA),
    .rx_in(rx_in),
    .data_out(data_register_out),
    .new_data_out(piece_data)
  );

    
  logic piece_weight;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(WEIGHT_BRAM_WIDTH / FRAME_SIZE)
  ) recv_weight (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(receive && header[1:0]==WEIGHT),
    .rx_in(rx_in),
    .data_out(weight_register_out),
    .new_data_out(piece_weight)
  );

  logic piece_op;
  recv #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(OP_BRAM_WIDTH / FRAME_SIZE)
  ) recv_op (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .receive_in(receive && header[1:0]==OP),
    .rx_in(rx_in),
    .data_out(op_register_out),
    .new_data_out(piece_op)
  );

  // TRANSMITTING (FPGA -> LAPTOP)
  logic transmit;
  assign tx_out = tx_data & tx_weight & tx_op & tx_inf;

  logic busy_transmitting_data;
  logic tx_data;
  trans #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(DATA_BRAM_WIDTH / FRAME_SIZE)
  ) trans_data (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_data_in(transmit && header[1:0]==DATA),
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
    .new_data_in(transmit && header[1:0]==WEIGHT),
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
    .new_data_in(transmit && header[1:0]==OP),
    .data_in(op_register_in),
    .tx_out(tx_op),
    .busy_out(busy_transmitting_op)
  );

  localparam INF_WIDTH = DATA_BRAM_WIDTH * DATA_PIECES / 2;
  localparam INF_PIECES = 1;

  logic busy_transmitting_inf;
  logic tx_inf;
  trans #(
    .CLK_BAUD_RATIO(CLK_BAUD_RATIO),
    .FRAME_SIZE(FRAME_SIZE),
    .FRAMES(INF_WIDTH / FRAME_SIZE)
  ) trans_inf (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .new_data_in(transmit && header[1:0]==INF),
    .data_in(inf_register_in),
    .tx_out(tx_inf),
    .busy_out(busy_transmitting_inf)
  );


  logic [$clog2(WEIGHT_PIECES+DATA_PIECES)-1:0] piece_counter; // Note: WEIGHT is widest type
  logic grabbed_register;
  always_ff @(posedge clk_in)begin
    receive <= 0;
    transmit <= 0;

    if (rst_in)begin
      busy_out <= 0;
    end else if (new_header)begin
      busy_out <= 1;
      receive <= !(header[2]);
      case (header[1:0])
        DATA: data_addr_out <= DATA_PIECES * header[HEADER_SIZE-1:HEADER_SIZE-ADDR_SIZE];
        WEIGHT: weight_addr_out <= WEIGHT_PIECES * header[HEADER_SIZE-1:HEADER_SIZE-ADDR_SIZE];
        OP: op_addr_out <= OP_PIECES * header[HEADER_SIZE-1:HEADER_SIZE-ADDR_SIZE];
        default: ;
      endcase
      piece_counter <= 0;
    end else if (busy_out)begin
      case (header[2:0])
        {WRITE, DATA}: begin // Write to DATA
          if (data_write_enable_out)begin
            data_write_enable_out <= 0;
            data_addr_out <= data_addr_out + 1;
            if (piece_counter == DATA_PIECES)begin
              busy_out <= 0;
            end else begin
              receive <= 1;
            end
          end
          if (piece_data)begin
            data_write_enable_out <= 1;
            piece_counter <= piece_counter + 1;
          end
        end
        {WRITE, WEIGHT}: begin // Write to WEIGHT
          if (weight_write_enable_out)begin
            weight_write_enable_out <= 0;
            weight_addr_out <= weight_addr_out + 1;
            if (piece_counter == WEIGHT_PIECES)begin
              busy_out <= 0;
            end else begin
              receive <= 1;
            end
          end
          if (piece_weight)begin
            weight_write_enable_out <= 1;
            piece_counter <= piece_counter + 1;
          end
        end
        {WRITE, OP}: begin // Write to OP
          if (op_write_enable_out)begin
            op_write_enable_out <= 0;
            op_addr_out <= op_addr_out + 1;
            if (piece_counter == OP_PIECES)begin
              busy_out <= 0;
            end else begin
              receive <= 1;
            end
          end
          if (piece_op)begin
            op_write_enable_out <= 1;
            piece_counter <= piece_counter + 1;
          end
        end
        {READ, DATA}: begin // Read from DATA
          if (!busy_transmitting_data && !transmit)begin
            if (grabbed_register)begin
              data_read_enable_out <= 0;
              transmit <= 1;
              grabbed_register <= 0;
              data_addr_out <= data_addr_out + 1;
            end else if(piece_counter == DATA_PIECES) begin
              busy_out <= 0;
            end else begin
              data_read_enable_out <= 1;
              grabbed_register <= 1;
              piece_counter <= piece_counter + 1;
            end
          end
        end
        {READ, WEIGHT}: begin // Read from WEIGHT
          if (!busy_transmitting_weight && !transmit)begin
            if (grabbed_register)begin
              weight_read_enable_out <= 0;
              transmit <= 1;
              grabbed_register <= 0;
              weight_addr_out <= weight_addr_out + 1;
            end else if(piece_counter == WEIGHT_PIECES) begin
              busy_out <= 0;
            end else begin
              weight_read_enable_out <= 1;
              grabbed_register <= 1;
              piece_counter <= piece_counter + 1;
            end
          end
        end
        {READ, OP}: begin // Read from OP
          if (!busy_transmitting_op && !transmit)begin
            if (grabbed_register)begin
              op_read_enable_out <= 0;
              transmit <= 1;
              grabbed_register <= 0;
              op_addr_out <= op_addr_out + 1;
            end else if(piece_counter == OP_PIECES) begin
              busy_out <= 0;
            end else begin
              op_read_enable_out <= 1;
              grabbed_register <= 1;
              piece_counter <= piece_counter + 1;
            end
          end
        end
        {READ, INF}: begin // Read from INF, untested but should work?
          if (!busy_transmitting_inf && !transmit)begin
            if (piece_counter == INF_PIECES)begin
              busy_out <= 0;
            end else begin
              transmit <= 1;
              piece_counter <= piece_counter + 1;
            end
          end
        end
        default:;
      endcase
    end
  end
endmodule // comms