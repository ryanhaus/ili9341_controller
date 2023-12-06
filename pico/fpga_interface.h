#include "pico/stdlib.h"
#include "hardware/spi.h"
#include <stdint.h>

#define FPGA_TFT_VSYNC_PIN 12
#define FPGA_TFT_DATA_ENABLE_PIN 13

#define FPGA_SPI_READY_PIN 9
#define FPGA_SCK_PIN 10
#define FGPA_SDA_PIN 11

#define FPGA_SPI_FREQ 10000000
#define FPGA_SPI_PORT spi1



void fpga_init() {
    // initialize vsync, data enable, and spi ready pins as inputs
    gpio_init(FPGA_TFT_VSYNC_PIN);
    gpio_init(FPGA_TFT_DATA_ENABLE_PIN);
    gpio_init(FPGA_SPI_READY_PIN);

    gpio_set_dir(FPGA_TFT_VSYNC_PIN, GPIO_IN);
    gpio_set_dir(FPGA_TFT_DATA_ENABLE_PIN, GPIO_IN);
    gpio_set_dir(FPGA_SPI_READY_PIN, GPIO_IN);



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



uint8_t fpga_read_vsync() {
    return gpio_get(FPGA_TFT_VSYNC_PIN);
}



uint8_t fpga_read_data_enable() {
    return gpio_get(FPGA_TFT_DATA_ENABLE_PIN);
}



uint8_t fpga_read_spi_ready() {
    return gpio_get(FPGA_SPI_READY_PIN);
}