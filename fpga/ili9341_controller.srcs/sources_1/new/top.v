module top(
    input sysclk,
    input reset,
    
    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    output tft_dotclk,
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [5:0] tft_data,
    
    output [18:0] MemAdr,
    inout [7:0] MemDB,
    output RamOEn,
    output RamWEn,
    output RamCEn,
    
    output uart_rxd_out
);
    // convert 12MHz input clock into 16.5312MHz dotclk (leads to an approx 60Hz vsync, assuming 3 clks/pixel, 328x280 pixels)
    tft_clk_wiz tft_clk_wiz_inst(
        .reset(reset),
        .clk_in1(sysclk),
        .clk_out1(tft_dotclk)
    );
    
    
    
    // drive the display
    wire memory_read;
    wire memory_write;
    
    ili9341_controller ili9341_controller_inst (
        .reset(reset),
        .enable(1'b1),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .spi_ready(spi_ready),
        .tft_dotclk(tft_dotclk),
        .tft_hsync(tft_hsync),
        .tft_vsync(tft_vsync),
        .tft_data_enable(tft_data_enable),
        .tft_data(tft_data),
        .memory_addr(MemAdr[15:0]),
        .memory_data(MemDB),
        .memory_read(memory_read),
        .memory_write(memory_write)
    );
    
    
    
    // for memory
    assign RamOEn = ~memory_read;
    assign RamWEn = ~memory_write;
    assign RamCEn = 0;
    assign MemAdr[18:16] = 0;
    
    
    
    // for UART communication: test, just send 0x0F a bunch of times at 19200 baud
    wire uart_active;
    
    uart_out #(
        .CLOCKS_PER_BIT(625) // 12MHz / 625 = 19200 baud rate
    ) uart_out_inst (
        .reset(reset),
        .enable(1),
        .clk(sysclk),
        .data_in(8'h0F),
        .start_transfer(~uart_active),
        .bit_clk(),
        .uart_out(uart_rxd_out),
        .transfer_active(uart_active)
    );
endmodule
