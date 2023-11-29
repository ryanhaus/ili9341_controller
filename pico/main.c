#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

#include "tft_interface.h"
#include "fpga_interface.h"

uint8_t red = 0;

int main() {
    tft_init();
    fpga_init();

    while (1) {
        fpga_write_data((uint8_t[]) { 0x00, 0x00, red++ }, 3);

        while (fpga_read_vsync() == 0) {
            // wait for vsync to go high
        }

        while (fpga_read_vsync() == 1) {
            // wait for vsync to go low
        }
    }
}