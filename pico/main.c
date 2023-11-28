#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

#include "tft_interface.h"
#include "fpga_interface.h"

int main() {
    tft_init();
    fpga_init();

    while (1) {
        fpga_write_data((uint8_t[]) { 0xFF, 0x00, 0x00 }, 3);
        sleep_ms(500);
        fpga_write_data((uint8_t[]) { 0x00, 0xFF, 0x00 }, 3);
        sleep_ms(500);
        fpga_write_data((uint8_t[]) { 0x00, 0x00, 0xFF }, 3);
        sleep_ms(500);
    }
}