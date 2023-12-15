/*
Copied from Manta with slight modifications. Available at this url:
https://github.com/fischermoseley/manta/blob/44a8c57dc53603da91c5dc8a9b68b211ff9ac182/src/manta/uart_iface/uart_rx.v
*/

module rx #(
    parameter CLK_BAUD_RATIO = 0,
    parameter DATA_SIZE = 8
  ) (
    input wire clk_in,
    input wire rst_in, // doesn't do anything

    input wire rx_in,

    output logic [DATA_SIZE-1:0] data_out,
    output logic new_data_out,
    output logic busy_out);

    localparam IDLE = 0;
    localparam BIT_ZERO = 1;
    localparam STOP_BIT = DATA_SIZE + 1;
    localparam state_size = $clog2(DATA_SIZE + 2);

    logic	[state_size:0] state = IDLE;
    assign busy_out = (state != IDLE);
    logic	[15:0] baud_counter = 0;
    logic zero_baud_counter;
    assign zero_baud_counter = (baud_counter == 0);

    // 2FF Synchronizer
    logic ck_uart = 1;
    logic	q_uart = 1;
    always @(posedge clk_in)
        { ck_uart, q_uart } <= { q_uart, rx_in };

    always @(posedge clk_in)
        if (state == IDLE) begin
            state <= IDLE;
            baud_counter <= 0;
            if (!ck_uart) begin
                state <= BIT_ZERO;
                baud_counter <= CLK_BAUD_RATIO+CLK_BAUD_RATIO/2-1'b1;
            end
        end

        else if (zero_baud_counter) begin
            state <= state + 1;
            baud_counter <= CLK_BAUD_RATIO-1'b1;
            if (state == STOP_BIT) begin
                state <= IDLE;
                baud_counter <= 0;
            end
        end

        else baud_counter <= baud_counter - 1'b1;

    always @(posedge clk_in)
        if ( (zero_baud_counter) && (state != STOP_BIT) )
            data_out <= {ck_uart, data_out[DATA_SIZE-1:1]};

    initial	new_data_out = 1'b0;
    always @(posedge clk_in)
        new_data_out <= ( (zero_baud_counter) && (state == STOP_BIT) );

endmodule