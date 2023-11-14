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
    wire last_tick_x;

    counter #(
        .MODULUS(X_MODULUS)
    ) x_counter (
        .clk(clk),
        .enable(enable),
        .reset(reset),
        .out(out_x),
        .last_tick(last_tick_x)
    );
    
    counter #(
        .MODULUS(Y_MODULUS)
    ) y_counter (
        .clk(clk),
        .enable(enable && last_tick_x),
        .reset(reset),
        .out(out_y),
        .last_tick()
    );
endmodule