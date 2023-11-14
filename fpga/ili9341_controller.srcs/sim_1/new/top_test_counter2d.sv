`timescale 1ns / 1ps

module top_test_counter2d();
    reg clk;
    
    localparam X_SIZE = 280;
    localparam X_BITS = $clog2(X_SIZE);
    
    localparam Y_SIZE = 320;
    localparam Y_BITS = $clog2(Y_SIZE);
    
    wire [X_BITS-1 : 0] x;
    wire [Y_BITS-1 : 0] y;
    
    initial clk = 1'b0;    
    always #1 clk = ~clk;
    
    wire [17:0] data;
    
    ili9341_controller controller_inst (
        .dotclk(clk),
        .hsync(hsync),
        .vsync(vsync),
        .data_enable(de),
        .data(data)
    );
endmodule
