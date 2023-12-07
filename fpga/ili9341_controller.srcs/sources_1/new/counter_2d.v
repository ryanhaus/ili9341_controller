// uses 2 counters to count along a 2D rectangle (the display)
module counter_2d #(
    parameter X_MODULUS = 10,
    localparam X_MODULUS_BITS = $clog2(X_MODULUS),
    
    parameter Y_MODULUS = 10,
    localparam Y_MODULUS_BITS = $clog2(Y_MODULUS)
) (
    input clk,
    input enable,
    input reset,
    
    output [X_MODULUS_BITS-1 : 0] out_x,
    output [Y_MODULUS_BITS-1 : 0] out_y
);
    wire overflow_x;

    counter #(
        .MODULUS(X_MODULUS)
    ) x_counter (
        .reset(reset),
        .enable(enable),
        .clk(clk),
        .out(out_x),
        .overflow(overflow_x)
    );
    
    counter #(
        .MODULUS(Y_MODULUS)
    ) y_counter (
        .reset(reset),
        .enable(enable && overflow_x),
        .clk(clk),
        .out(out_y),
        .overflow()
    );
endmodule