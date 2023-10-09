function integer clog3(input integer value);
    integer result;
    result = 0;
    
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

function integer n3(input integer x, input integer n);
    // Next integer in ternary, if we increase the nth trit (no carrrying).
    return x - (x % (3**(n+1))) + ((x + 3**n) % (3**(n+1)));
endfunction

function integer p3(input integer x, input integer n);
    // Previous integer in ternary, if we decrease the nth trit (no carrrying).
    return x - (x % (3**(n+1))) + ((x - 3**n) % (3**(n+1)));
endfunction

function bit z3(input integer x, input integer n);
    // Is the nth trit a zero?
    return ((x - 3**n) % (3**(n+1))) > (x % (3**(n+1)));
endfunction