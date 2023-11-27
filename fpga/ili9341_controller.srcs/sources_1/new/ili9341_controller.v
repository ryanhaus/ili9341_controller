// this module uses a display_handler instance to drive sync signals, and also generates the video output
module ili9341_controller(
    input reset,
    input enable,
    
    input tft_dotclk,
    
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [5:0] tft_data
);
    // determine sync signals & where we are on the display
    wire [$clog2(240)-1 : 0] tft_display_x;
    wire [$clog2(320)-1 : 0] tft_display_y;
    wire [1:0] dotclk_count;
    
    display_handler display_handler_inst (
        .reset(reset),
        .enable(enable),
        .dotclk(tft_dotclk),
        .dotclk_count(dotclk_count),
        .hsync(tft_hsync),
        .vsync(tft_vsync),
        .data_enable(tft_data_enable),
        .display_x(tft_display_x),
        .display_y(tft_display_y)
    );
    
    
    
    // test: color gradients
    reg [5:0] red;
    reg [5:0] green;
    reg [5:0] blue;
    
    always @(*) begin
        red = tft_display_x;
        green = tft_display_y;
        blue = 6'b0;
    end
    
    
    
    // for outputting colors to the data bus
    color_mux color_mux_inst(
        .enable(tft_data_enable),
        .selector(dotclk_count),
        .red(red),
        .green(green),
        .blue(blue),
        .data(tft_data)
    );
endmodule