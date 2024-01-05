// this module uses a display_handler instance to drive sync signals, and also generates the video output
module ili9341_controller(
    input reset,
    input enable,
    
    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    input sm_clock,
    
    output reg tft_dotclk,
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [15:0] tft_data
);
    // determine sync signals & where we are on the display
    wire [$clog2(240)-1 : 0] tft_display_x;
    wire [$clog2(320)-1 : 0] tft_display_y;
    wire [$clog2(240)-1 : 0] tft_next_display_x;
    wire tft_next_display_x_on_screen;
    wire posclk;
    
    display_handler display_handler_inst (
        .reset(reset),
        .enable(enable),
        .dotclk(tft_dotclk),
        .pixel_clock(posclk),
        .hsync(tft_hsync),
        .vsync(tft_vsync),
        .data_enable(tft_data_enable),
        .display_x(tft_display_x),
        .display_y(tft_display_y),
        .next_display_x(tft_next_display_x),
        .next_display_x_on_screen(tft_next_display_x_on_screen)
    );
    
    
    
    // test: spi memory writing, memory reading for display 
    spi_video_memory video_memory_inst (
        .reset(reset),
        .clk(sm_clock),
        .dotclk(tft_dotclk),
        .posclk(posclk),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .spi_ready(spi_ready),
        .display_x(tft_display_x),
        .display_y(tft_display_y),
        .in_display_region(tft_data_enable),
        .current_pixel(tft_data)
    );
endmodule