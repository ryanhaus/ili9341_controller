`timescale 1ns / 1ps

module top_sim();
    reg sysclk;
    always #83 sysclk = ~sysclk; // close enough to 12MHz
   
    
    wire tft_dotclk;
    wire tft_hsync;
    wire tft_vsync;
    wire tft_data_enable;
    wire [17:0] tft_data;
    
    top top_inst(
        .sysclk(sysclk),
        .tft_dotclk(tft_dotclk),
        .tft_hsync(tft_hsync),
        .tft_vsync(tft_vsync),
        .tft_data_enable(tft_data_enable),
        .tft_data(tft_data)
    );
endmodule
