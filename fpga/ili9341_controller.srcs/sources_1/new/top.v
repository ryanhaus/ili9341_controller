module top(
    input sysclk,
    
    output tft_dotclk,
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [17:0] tft_data
);
    // convert 12MHz input clock into 5.5104MHz dotclk (leads to an approx 60Hz vsync)
    tft_clk_wiz tft_clk_wiz_inst(
        .reset(1'b0),
        .clk_in1(sysclk),
        .clk_out1(tft_dotclk)
    );
    
    
    
    // drive the display
    ili9341_controller ili9341_controller_inst (
        .tft_dotclk(tft_dotclk),
        .tft_hsync(tft_hsync),
        .tft_vsync(tft_vsync),
        .tft_data_enable(tft_data_enable),
        .tft_data(tft_data)
    );
endmodule
