module top(
    input sysclk,
    
    output tft_dotclk,
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [17:0] tft_data
);
    wire tft_dotclk;
    tft_clk_wiz tft_clk_wiz_inst(
        .reset(1'b0),
        .clk_in1(sysclk),
        .clk_out1(tft_dotclk)
    );
    
    
    
    ili9341_controller ili9341_controller_inst(
        .dotclk(tft_dotclk),
        .hsync(tft_hsync),
        .vsync(tft_vsync),
        .data_enable(tft_data_enable),
        .data(tft_data)
    );
endmodule
