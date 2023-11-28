#include "pico/stdlib.h"
#include "hardware/spi.h"

#define FPGA_SCK_PIN 10
#define FGPA_SDA_PIN 11

#define FPGA_SPI_FREQ 25000000
#define FPGA_SPI_PORT spi1



void fpga_init() {
    // initialize SPI
    spi_init(FPGA_SPI_PORT, FPGA_SPI_FREQ);

    spi_set_format(
        FPGA_SPI_PORT,
        8, // data bits
        SPI_CPOL_0, // clock polarity
        SPI_CPHA_0, // clock phase
        SPI_MSB_FIRST // data order
    );

    gpio_set_function(FPGA_SCK_PIN, GPIO_FUNC_SPI);
    gpio_set_function(FGPA_SDA_PIN, GPIO_FUNC_SPI);
}



void fpga_write_data(uint8_t* data, size_t n) {
    spi_write_blocking(FPGA_SPI_PORT, data, n);
}