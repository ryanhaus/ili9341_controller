module top(
    input sysclk,
    input reset,
    
    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    output tft_dotclk,
    output reg tft_hsync,
    output reg tft_vsync,
    output reg tft_data_enable,
    output [15:0] tft_data
);    
    // creates a 22.0416MHz clock from the 12MHz system clock
    // this module is automatically generated by the icepll tool during build
    wire sm_clock; // state machine clock, operates at 4x the frequency of the TFT dotclk

    dotclk_pll dotclk_pll_inst (
        .clock_in(sysclk),
        .clock_out(sm_clock),
        .locked()
    );

    

    // drive the display
    ili9341_controller ili9341_controller_inst (
        .reset(reset),
        .enable(1),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .spi_ready(spi_ready),
        .sm_clock(sm_clock),
        .tft_dotclk(tft_dotclk),
        .tft_hsync(hsync),
        .tft_vsync(vsync),
        .tft_data_enable(data_enable),
        .tft_data(tft_data)
    );
endmodule