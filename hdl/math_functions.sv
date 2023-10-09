function integer clog3(input integer value);
    integer result = 0;
    
    if (value <= 0) begin
        // Handle invalid input
        $display("Error: Input to clog3 must be a non-negative integer.");
        assert(0) else $fatal;
    end else begin
        while (value > 1) begin
            value /= 3;
            result++;
        end
    end
    
    return result;
endfunction