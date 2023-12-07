module ili9341_verilator(
    input spi_sck,
    input spi_sda,
    output spi_ready,
    input tft_dotclk,
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [5:0] tft_data
);
    wire [18:0] memory_addr;
    wire [7:0] memory_data;
    wire memory_read;
    wire memory_write;
    
    assign memory_addr[18:16] = 0;
    
    ili9341_controller ili9341_controller_inst (
        .reset(1'b0),
        .enable(1'b1),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .spi_ready(spi_ready),
        .tft_dotclk(tft_dotclk),
        .tft_hsync(tft_hsync),
        .tft_vsync(tft_vsync),
        .tft_data_enable(tft_data_enable),
        .tft_data(tft_data),
        .memory_addr(memory_addr[15:0]),
        .memory_data(memory_data),
        .memory_read(memory_read),
        .memory_write(memory_write)
    );
    
    
    
    sim_sram #(
        .ADDR_BITS(16) // TODO: change to allow sim to access all 18 bits
    ) sim_sram_inst (
        .clk(spi_sck),
        .mem_addr(memory_addr[15:0]),
        .mem_data(memory_data),
        .mem_read(memory_read),
        .mem_write(memory_write)
    );
endmodule
