#include <stdlib.h>
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

#include "tft_interface.h"
#include "fpga_interface.h"

int main() {
    // initialize TFT and FPGA
    tft_init();
    fpga_init();

    // wait until the FPGA is ready
    while (!fpga_read_spi_ready()) {}

    // turn LED on
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
    gpio_put(PICO_DEFAULT_LED_PIN, 1);
    
    // loop
    uint16_t i = 0;

    while (1) {
        while (!fpga_read_spi_ready()) {}

        fpga_write_data((uint8_t[]) { i >> 8, i & 0xFF, i % 240 }, 3);
        i++;
    }
}