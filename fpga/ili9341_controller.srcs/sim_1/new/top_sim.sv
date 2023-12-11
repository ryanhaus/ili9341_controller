`timescale 1ns/1ps

module top_sim();
    reg sysclk;
    initial sysclk = 0;
    always #42 sysclk = ~sysclk; // close enough to 12MHz
   
    reg reset;
    initial reset = 1; // active low
    
    reg spi_sck;
    reg spi_sda;
    wire spi_ready;
    wire tft_dotclk;
    wire tft_hsync;
    wire tft_vsync;
    wire tft_data_enable;
    wire [5:0] tft_data;
    wire [18:0] memory_addr;
    wire [7:0] memory_data;
    wire RamOEn;
    wire RamWEn;
    wire RamCEn;
    wire uart_out;
    
    top top_inst(
        .sysclk(sysclk),
        .reset(reset),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .spi_ready(spi_ready),
        .tft_dotclk(tft_dotclk),
        .tft_hsync(tft_hsync),
        .tft_vsync(tft_vsync),
        .tft_data_enable(tft_data_enable),
        .tft_data(tft_data),
        .MemAdr(memory_addr),
        .MemDB(memory_data),
        .RamOEn(RamOEn),
        .RamWEn(RamWEn),
        .RamCEn(RamCEn),
        .rp_uart_tx(uart_out)
    );
    
    
    
    wire memory_read;
    wire memory_write;
    wire memory_enable;
    assign memory_read = ~RamOEn;
    assign memory_write = ~RamWEn;
    assign memory_enable = ~RamCEn;
    
    
    
    sim_sram #(
        .ADDR_BITS(16) // TODO: change to allow sim to access all 18 bits
    ) sim_sram_inst (
        .clk(spi_sck),
        .mem_addr(memory_addr[15:0]),
        .mem_data(memory_data),
        .mem_read(memory_read),
        .mem_write(memory_write)
    );
    
    
    
    integer i;
    integer j = 0;
    
    always begin        
        if (spi_ready) begin
            for (i = 0; i < 24; i = i + 1) begin
                #2
                spi_sda <= i < 16 ? j[15 - i] : j[23 - i];
                spi_sck <= 0;
                #2
                spi_sck <= 1;
            end
            
            j = j + 1;
        end else #10 i=i;
    end
endmodule
