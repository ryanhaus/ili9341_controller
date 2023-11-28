`timescale 1ns / 1ps

module top_sim();
    reg sysclk;
    initial sysclk = 0;
    always #42 sysclk = ~sysclk; // close enough to 12MHz
   
    
    reg spi_sck;
    reg spi_sda;
    wire tft_dotclk;
    wire tft_hsync;
    wire tft_vsync;
    wire tft_data_enable;
    wire [5:0] tft_data;
    
    top top_inst(
        .sysclk(sysclk),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .tft_dotclk(tft_dotclk),
        .tft_hsync(tft_hsync),
        .tft_vsync(tft_vsync),
        .tft_data_enable(tft_data_enable),
        .tft_data(tft_data)
    );
    
    
    
    initial begin
        integer i;
        
        for (i = 0; i < 24; i = i + 1) begin
            #20
            spi_sda <= (i < 8);
            spi_sck <= 0;
            #20
            spi_sck <= 1;
        end
    end
endmodule
