module top(
    input sysclk,
    input tft_dotclk,
    input reset,
    
    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [5:0] tft_data,
    
    output [18:0] MemAdr,
    inout [7:0] MemDB,
    output RamOEn,
    output RamWEn,
    output RamCEn,
    
    output rp_uart_tx
);
    wire reset_active_low = ~reset;
    
    // drive the display
    wire memory_read;
    wire memory_write;
    
    ili9341_controller ili9341_controller_inst (
        .reset(reset_active_low),
        .enable(1),
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
    
    
    
    // for UART communication: test, just send a counter stream at 19200 baud
    reg [7:0] uart_counter = 0;
    wire uart_active;
    
    uart_out #(
        .CLOCKS_PER_BIT(625) // 12MHz / 625 = 19200 baud rate
    ) uart_out_inst (
        .reset(reset_active_low),
        .enable(1),
        .clk(sysclk),
        .data_in(uart_counter),
        .start_transfer(~uart_active),
        .bit_clk(),
        .uart_out(rp_uart_tx),
        .transfer_active(uart_active)
    );
    
    always @(posedge uart_active) begin
        uart_counter = uart_counter + 1;
    end
endmodule
