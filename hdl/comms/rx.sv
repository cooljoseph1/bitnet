module rx #(
    parameter CLK_BAUD_RATIO = 8;
) (
    input wire clk_in,
    input wire rst_in,
    input wire tx_in,
    output op op_code_out,
  );

    logic receiving;
    op op_code;
    logic [$clog2(CLK_BAUD_RATIO)-1:0] baud_checker;
    logic [1:0] counter;
    always_ff @(posedge clk_in)begin
        baud_checker <= baud_checker == CLK_BAUD_RATIO-1? 0 : baud_checker + 1;
        if (rst_in)begin
            receiving <= 0;
            op_code <= 0;
            baud_checker <= 0;
            counter <= 0;
        end else if (baud_checker == 0) begin
            if (!receiving && tx_in) begin // start receiving
                receiving <= 0;
                counter <= 0;
            end else if (receiving) begin
                counter <= counter + 1;
                op_code_out[counter] <= tx_in;
                if (counter == 3) begin
                    receiving <= 0;
                end
            end
        end
    end
endmodule