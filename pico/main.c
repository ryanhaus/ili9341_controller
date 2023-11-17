#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

#define TFT_SCK_PIN 2
#define TFT_SDA_PIN 3
#define TFT_RST_PIN 5
#define TFT_CS_PIN 14
#define TFT_DC_PIN 15

#define TFT_SPI_FREQ 1000000
#define TFT_SPI_PORT spi0



void spi_write_command(spi_inst_t* spi, uint8_t cmd, uint8_t* args, size_t args_len) {
    gpio_put(TFT_CS_PIN, 0);

    gpio_put(TFT_DC_PIN, 0);
    spi_write_blocking(spi, &cmd, 1);

    gpio_put(TFT_DC_PIN, 1);
    spi_write_blocking(spi, args, args_len);


    gpio_put(TFT_CS_PIN, 1);
}




int main() {
    // initialize CS, DC, and RST pins
    gpio_init(TFT_CS_PIN);
    gpio_init(TFT_DC_PIN);
    gpio_init(TFT_RST_PIN);

    // set CS, DC, and RST pins to output
    gpio_set_dir(TFT_CS_PIN, GPIO_OUT);
    gpio_set_dir(TFT_DC_PIN, GPIO_OUT);
    gpio_set_dir(TFT_RST_PIN, GPIO_OUT);

    // default CS, DC, and RST pins to high
    gpio_put(TFT_CS_PIN, 1);
    gpio_put(TFT_DC_PIN, 1);
    gpio_put(TFT_RST_PIN, 1);



    // initialize SPI
    spi_init(TFT_SPI_PORT, TFT_SPI_FREQ);

    spi_set_format(
        TFT_SPI_PORT,
        8, // data bits
        0, // clock polarity
        0, // clock phase
        SPI_MSB_FIRST // data order
    );
    
    gpio_set_function(TFT_SCK_PIN, GPIO_FUNC_SPI);
    gpio_set_function(TFT_SDA_PIN, GPIO_FUNC_SPI);
    


    // reset
    sleep_ms(100);
    gpio_put(TFT_RST_PIN, 0);
    sleep_ms(100);
    gpio_put(TFT_RST_PIN, 1);
    sleep_ms(100);



    // startup sequence
    spi_write_command(TFT_SPI_PORT, 0x01, NULL, 0); // software reset
    sleep_ms(120);
    spi_write_command(TFT_SPI_PORT, 0xEF, (uint8_t[]) { 0x03, 0x80, 0x02 }, 3); // ?
    spi_write_command(TFT_SPI_PORT, 0xCF, (uint8_t[]) { 0x00, 0xC1, 0x30 }, 3); // power control B
    spi_write_command(TFT_SPI_PORT, 0xED, (uint8_t[]) { 0x64, 0x03, 0x12, 0x81 }, 4); // power on sequence control
    spi_write_command(TFT_SPI_PORT, 0xE8, (uint8_t[]) { 0x85, 0x00, 0x78 }, 3); // driver timing control A
    spi_write_command(TFT_SPI_PORT, 0xCB, (uint8_t[]) { 0x39, 0x2C, 0x00, 0x34, 0x02 }, 5); // power control A
    spi_write_command(TFT_SPI_PORT, 0xF7, (uint8_t[]) { 0x20 }, 1); // pump ratio control
    spi_write_command(TFT_SPI_PORT, 0xEA, (uint8_t[]) { 0x00, 0x00 }, 2); // driver timing control B
    spi_write_command(TFT_SPI_PORT, 0xC0, (uint8_t[]) { 0x23 }, 1); // power control 1
    spi_write_command(TFT_SPI_PORT, 0xC1, (uint8_t[]) { 0x10 }, 1); // power control 2
    spi_write_command(TFT_SPI_PORT, 0xC5, (uint8_t[]) { 0x3E, 0x28 }, 2); // VCOM control 1
    spi_write_command(TFT_SPI_PORT, 0xC7, (uint8_t[]) { 0x86 }, 1); // VCOM control 2
    spi_write_command(TFT_SPI_PORT, 0x36, (uint8_t[]) { 0x00 }, 1); // memory access control
    spi_write_command(TFT_SPI_PORT, 0x37, (uint8_t[]) { 0x00 }, 1); // vertical scroll start address
    spi_write_command(TFT_SPI_PORT, 0x3A, (uint8_t[]) { 0x66 }, 1); // pixel format set
    spi_write_command(TFT_SPI_PORT, 0xB0, (uint8_t[]) { 0x40 }, 1); // RGB interface control
    spi_write_command(TFT_SPI_PORT, 0xB1, (uint8_t[]) { 0x00, 0x1F }, 2); // frame rate control
    spi_write_command(TFT_SPI_PORT, 0xB5, (uint8_t[]) { 0x02, 0x02, 0x0A, 0x14 }, 4); // blanking porch control
    spi_write_command(TFT_SPI_PORT, 0xB6, (uint8_t[]) { 0x08, 0x82, 0x27 }, 3); // display function control
    spi_write_command(TFT_SPI_PORT, 0xF2, (uint8_t[]) { 0x00 }, 1); // 3 gamma function enable
    spi_write_command(TFT_SPI_PORT, 0x26, (uint8_t[]) { 0x01 }, 1); // gamma curve selected
    spi_write_command(TFT_SPI_PORT, 0xE0, (uint8_t[]) { 0x0F, 0x31, 0x2B, 0x0C, 0x0E, 0x08, 0x4E, 0xF1, 0x37, 0x07, 0x10, 0x03, 0x0E, 0x09, 0x00 }, 15); // positive gamma correction
    spi_write_command(TFT_SPI_PORT, 0xE1, (uint8_t[]) { 0x00, 0x0E, 0x14, 0x03, 0x11, 0x07, 0x31, 0xC1, 0x48, 0x08, 0x0F, 0x0C, 0x31, 0x36, 0x0F }, 15); // negative gamma correction
    spi_write_command(TFT_SPI_PORT, 0xF6, (uint8_t[]) { 0x09, 0x00, 0x06 }, 3); // interface control
    spi_write_command(TFT_SPI_PORT, 0x11, NULL, 0); // sleep out
    sleep_ms(120);
    spi_write_command(TFT_SPI_PORT, 0x29, NULL, 0); // display on

    return 0;
}